//
//  RealSignatureService.swift
//  z1-app-mvp
//
//  Created by Amit Anand on 7/19/25.
//

import Foundation

class RealSignatureService: SignatureService {
    private let secureEnclaveManager: SecureEnclaveManager
    
    init(secureEnclaveManager: SecureEnclaveManager) {
        self.secureEnclaveManager = secureEnclaveManager
    }
    
    func sign(hash: String) async throws -> (signature: String, publicKey: String) {
        // Ensure we have a keypair
        let hasKeypair = await MainActor.run {
            secureEnclaveManager.hasKeypair
        }
        
        if !hasKeypair {
            // Generate keypair on first use
            _ = try await secureEnclaveManager.generateKeypair()
        }
        
        // Sign the hash using Secure Enclave
        let signatureData = try await secureEnclaveManager.sign(hash: hash)
        let signature = signatureData.base64EncodedString()
        
        // Get public key for verification
        let publicKey = try await secureEnclaveManager.getPublicKeyString()
        
        return (signature: signature, publicKey: publicKey)
    }
} 