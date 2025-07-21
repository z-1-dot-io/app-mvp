//
//  DummySignatureService.swift
//  z1-app-mvp
//
//  Created by Amit Anand on 7/19/25.
//

import Foundation

class DummySignatureService: SignatureService {
    func sign(hash: String) async throws -> (signature: String, publicKey: String) {
        // Simulate processing time
        try await Task.sleep(nanoseconds: 300_000_000) // 300ms
        
        // Return dummy signature and public key
        let signature = "dummy_signature_1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef"
        let publicKey = "dummy_public_key_1234567890abcdef1234567890abcdef1234567890abcdef"
        
        return (signature: signature, publicKey: publicKey)
    }
} 