//
//  DummyHashingService.swift
//  z1-app-mvp
//
//  Created by Amit Anand on 7/19/25.
//

import Foundation
import PhotosUI

class DummyHashingService: HashingService {
    func hash(photo: PhotosPickerItem) async throws -> String {
        // Simulate processing time
        try await Task.sleep(nanoseconds: 200_000_000) // 200ms
        
        // Return a dummy SHA-256 hash
        return "a1b2c3d4e5f6789012345678901234567890abcdef1234567890abcdef12345678"
    }
} 