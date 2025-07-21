//
//  SecureEnclaveManager.swift
//  z1-app-mvp
//
//  Created by Amit Anand on 7/19/25.
//

import Foundation
import Security
import CryptoKit

enum SecureEnclaveError: Error, LocalizedError {
    case secureEnclaveNotAvailable
    case keyGenerationFailed
    case keyRetrievalFailed
    case signingFailed
    case publicKeyExtractionFailed
    case keychainError(OSStatus)
    
    var errorDescription: String? {
        switch self {
        case .secureEnclaveNotAvailable:
            return "Secure Enclave is not available on this device"
        case .keyGenerationFailed:
            return "Failed to generate keypair in Secure Enclave"
        case .keyRetrievalFailed:
            return "Failed to retrieve keypair from Secure Enclave"
        case .signingFailed:
            return "Failed to sign data with Secure Enclave"
        case .publicKeyExtractionFailed:
            return "Failed to extract public key from Secure Enclave"
        case .keychainError(let status):
            return "Keychain error: \(status)"
        }
    }
}

class SecureEnclaveManager: ObservableObject {
    // MARK: - Properties
    private let keyTag = "com.z1.secureenclave.keypair"
    private let keychainQuery: [String: Any] = [
        kSecClass as String: kSecClassKey,
        kSecAttrKeyType as String: kSecAttrKeyTypeECSECPrimeRandom,
        kSecAttrKeySizeInBits as String: 256,
        kSecAttrTokenID as String: kSecAttrTokenIDSecureEnclave,
        kSecPrivateKeyAttrs as String: [
            kSecAttrIsPermanent as String: true,
            kSecAttrApplicationTag as String: "com.z1.secureenclave.keypair"
        ]
    ]
    
    @Published var isSecureEnclaveAvailable: Bool = false
    @Published var hasKeypair: Bool = false
    @Published var errorMessage: String?
    
    // MARK: - Initialization
    init() {
        checkSecureEnclaveAvailability()
        // Note: checkForKeypair() will be called asynchronously when needed
    }
    
    // MARK: - Public Methods
    
    /// Check if Secure Enclave is available on this device
    func checkSecureEnclaveAvailability() {
        isSecureEnclaveAvailable = SecureEnclave.isAvailable
    }
    
    /// Check if a keypair already exists
    @MainActor
    func checkForKeypair() {
        do {
            _ = try getPrivateKey()
            hasKeypair = true
        } catch {
            hasKeypair = false
        }
    }
    
    /// Generate a new keypair in Secure Enclave
    func generateKeypair() async throws -> SecKey {
        guard isSecureEnclaveAvailable else {
            throw SecureEnclaveError.secureEnclaveNotAvailable
        }
        
        do {
            // Generate private key in Secure Enclave
            guard let privateKey = SecKeyCreateRandomKey(keychainQuery as CFDictionary, nil) else {
                throw SecureEnclaveError.keyGenerationFailed
            }
            
            // Extract public key
            guard let publicKey = SecKeyCopyPublicKey(privateKey) else {
                throw SecureEnclaveError.publicKeyExtractionFailed
            }
            
            // Store public key reference in Keychain for persistence
            try storePublicKeyReference(publicKey)
            
            await MainActor.run {
                hasKeypair = true
            }
            return privateKey
        } catch {
            throw SecureEnclaveError.keyGenerationFailed
        }
    }
    
    /// Get existing private key from Secure Enclave
    func getPrivateKey() throws -> SecKey {
        let query: [String: Any] = [
            kSecClass as String: kSecClassKey,
            kSecAttrKeyType as String: kSecAttrKeyTypeECSECPrimeRandom,
            kSecAttrApplicationTag as String: keyTag,
            kSecAttrTokenID as String: kSecAttrTokenIDSecureEnclave,
            kSecReturnRef as String: true
        ]
        
        var result: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        guard status == errSecSuccess, let result = result else {
            throw SecureEnclaveError.keyRetrievalFailed
        }
        
        return result as! SecKey
    }
    
    /// Get public key reference from Keychain
    func getPublicKey() throws -> SecKey {
        let query: [String: Any] = [
            kSecClass as String: kSecClassKey,
            kSecAttrKeyType as String: kSecAttrKeyTypeECSECPrimeRandom,
            kSecAttrApplicationTag as String: "\(keyTag).public",
            kSecReturnRef as String: true
        ]
        
        var result: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        guard status == errSecSuccess, let result = result else {
            throw SecureEnclaveError.keyRetrievalFailed
        }
        
        return result as! SecKey
    }
    
    /// Sign data using Secure Enclave private key
    func sign(data: Data) async throws -> Data {
        guard isSecureEnclaveAvailable else {
            throw SecureEnclaveError.secureEnclaveNotAvailable
        }
        
        guard hasKeypair else {
            throw SecureEnclaveError.keyRetrievalFailed
        }
        
        do {
            let privateKey = try getPrivateKey()
            
            // Create signature using Secure Enclave
            let algorithm = SecKeyAlgorithm.ecdsaSignatureMessageX962SHA256
            guard let signature = SecKeyCreateSignature(privateKey, algorithm, data as CFData, nil) else {
                throw SecureEnclaveError.signingFailed
            }
            
            return signature as Data
        } catch {
            throw SecureEnclaveError.signingFailed
        }
    }
    
    /// Sign hash string (converts to Data first)
    func sign(hash: String) async throws -> Data {
        guard let hashData = hash.data(using: .utf8) else {
            throw SecureEnclaveError.signingFailed
        }
        
        return try await sign(data: hashData)
    }
    
    /// Get public key as base64 string for display
    func getPublicKeyString() async throws -> String {
        let publicKey = try getPublicKey()
        
        // Export public key data
        let query: [String: Any] = [
            kSecValueRef as String: publicKey,
            kSecReturnData as String: true
        ]
        
        var result: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        guard status == errSecSuccess, let keyData = result as? Data else {
            throw SecureEnclaveError.publicKeyExtractionFailed
        }
        
        return keyData.base64EncodedString()
    }
    
    /// Delete existing keypair (for testing/reset)
    func deleteKeypair() throws {
        let privateKeyQuery: [String: Any] = [
            kSecClass as String: kSecClassKey,
            kSecAttrApplicationTag as String: keyTag,
            kSecAttrTokenID as String: kSecAttrTokenIDSecureEnclave
        ]
        
        let publicKeyQuery: [String: Any] = [
            kSecClass as String: kSecClassKey,
            kSecAttrApplicationTag as String: "\(keyTag).public"
        ]
        
        SecItemDelete(privateKeyQuery as CFDictionary)
        SecItemDelete(publicKeyQuery as CFDictionary)
        
        Task { @MainActor in
            hasKeypair = false
        }
    }
    
    // MARK: - Private Methods
    
    private func storePublicKeyReference(_ publicKey: SecKey) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassKey,
            kSecValueRef as String: publicKey,
            kSecAttrApplicationTag as String: "\(keyTag).public",
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        ]
        
        let status = SecItemAdd(query as CFDictionary, nil)
        
        if status != errSecSuccess && status != errSecDuplicateItem {
            throw SecureEnclaveError.keychainError(status)
        }
    }
}

// MARK: - Secure Enclave Availability Check
struct SecureEnclave {
    static var isAvailable: Bool {
        // Check if device supports Secure Enclave (A11+)
        if #available(iOS 11.0, *) {
            // Create a temporary key to test Secure Enclave support
            let testQuery: [String: Any] = [
                kSecClass as String: kSecClassKey,
                kSecAttrKeyType as String: kSecAttrKeyTypeECSECPrimeRandom,
                kSecAttrKeySizeInBits as String: 256,
                kSecAttrTokenID as String: kSecAttrTokenIDSecureEnclave,
                kSecAttrIsPermanent as String: false
            ]
            
            return SecKeyCreateRandomKey(testQuery as CFDictionary, nil) != nil
        }
        return false
    }
} 