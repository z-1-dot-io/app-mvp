//
//  SignatureService.swift
//  z1-app-mvp
//
//  Created by Amit Anand on 7/19/25.
//

import Foundation

protocol SignatureService {
    func sign(hash: String) async throws -> (signature: String, publicKey: String)
} 