//
//  SignatureData.swift
//  z1-app-mvp
//
//  Created by Amit Anand on 7/19/25.
//

import Foundation

struct SignatureData: Identifiable, Codable {
    var id = UUID()
    let hash: String
    let signature: String
    let publicKey: String
    let signedDate: Date
    
    init(hash: String, signature: String, publicKey: String) {
        self.hash = hash
        self.signature = signature
        self.publicKey = publicKey
        self.signedDate = Date()
    }
} 