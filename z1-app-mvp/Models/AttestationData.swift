//
//  AttestationData.swift
//  z1-app-mvp
//
//  Created by Amit Anand on 7/19/25.
//

import Foundation

struct AttestationData: Identifiable, Codable {
    var id = UUID()
    let hash: String
    let signature: String
    let publicKey: String
    let transactionHash: String
    let attestedDate: Date
    
    init(hash: String, signature: String, publicKey: String, transactionHash: String) {
        self.hash = hash
        self.signature = signature
        self.publicKey = publicKey
        self.transactionHash = transactionHash
        self.attestedDate = Date()
    }
} 