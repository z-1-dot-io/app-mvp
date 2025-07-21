//
//  DummyAttestationService.swift
//  z1-app-mvp
//
//  Created by Amit Anand on 7/19/25.
//

import Foundation

class DummyAttestationService: AttestationService {
    func attest(hash: String, signature: String, publicKey: String) async throws -> String {
        // Simulate processing time
        try await Task.sleep(nanoseconds: 250_000_000) // 250ms
        
        // Return dummy transaction hash
        return "0xdeadbeef1234567890abcdef1234567890abcdef1234567890abcdef12345678"
    }
} 