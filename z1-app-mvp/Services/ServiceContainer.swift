//
//  ServiceContainer.swift
//  z1-app-mvp
//
//  Created by Amit Anand on 7/19/25.
//

import Foundation

@MainActor
class ServiceContainer: ObservableObject {
    let hashingService: HashingService
    let signatureService: SignatureService
    let attestationService: AttestationService
    let secureEnclaveManager: SecureEnclaveManager
    
    init(
        hashingService: HashingService? = nil,
        signatureService: SignatureService? = nil,
        attestationService: AttestationService = DummyAttestationService()
    ) {
        // Initialize Secure Enclave manager
        self.secureEnclaveManager = SecureEnclaveManager()
        
        // Use real services when available, otherwise use dummy services
        if secureEnclaveManager.isSecureEnclaveAvailable {
            self.hashingService = hashingService ?? RealHashingService()
            self.signatureService = signatureService ?? RealSignatureService(secureEnclaveManager: secureEnclaveManager)
        } else {
            self.hashingService = hashingService ?? DummyHashingService()
            self.signatureService = signatureService ?? DummySignatureService()
        }
        
        self.attestationService = attestationService
    }
} 