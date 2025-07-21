//
//  AttestationService.swift
//  z1-app-mvp
//
//  Created by Amit Anand on 7/19/25.
//

import Foundation

protocol AttestationService {
    func attest(hash: String, signature: String, publicKey: String) async throws -> String
} 