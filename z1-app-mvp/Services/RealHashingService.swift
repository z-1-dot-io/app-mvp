//
//  RealHashingService.swift
//  z1-app-mvp
//
//  Created by Amit Anand on 7/19/25.
//

import Foundation
import PhotosUI
import CryptoKit

enum HashingError: Error, LocalizedError {
    case photoDataExtractionFailed
    case photoDataEmpty
    case hashingFailed
    case unsupportedPhotoFormat
    
    var errorDescription: String? {
        switch self {
        case .photoDataExtractionFailed:
            return "Failed to extract photo data"
        case .photoDataEmpty:
            return "Photo data is empty"
        case .hashingFailed:
            return "Failed to hash photo data"
        case .unsupportedPhotoFormat:
            return "Unsupported photo format"
        }
    }
}

class RealHashingService: HashingService {
    
    /// Extract photo data from PhotosPickerItem
    private func extractPhotoData(from item: PhotosPickerItem) async throws -> Data {
        do {
            guard let data = try await item.loadTransferable(type: Data.self) else {
                throw HashingError.photoDataExtractionFailed
            }
            
            guard !data.isEmpty else {
                throw HashingError.photoDataEmpty
            }
            
            return data
        } catch {
            throw HashingError.photoDataExtractionFailed
        }
    }
    
    /// Hash photo data using SHA-256
    private func hashPhotoData(_ data: Data) async throws -> String {
        do {
            // Use CryptoKit SHA-256 for hashing
            let hash = SHA256.hash(data: data)
            
            // Convert to hex string
            let hexString = hash.compactMap { String(format: "%02x", $0) }.joined()
            
            return hexString
        } catch {
            throw HashingError.hashingFailed
        }
    }
    
    /// Main hashing method that extracts data and generates hash
    func hash(photo: PhotosPickerItem) async throws -> String {
        // Extract photo data
        let photoData = try await extractPhotoData(from: photo)
        
        // Generate SHA-256 hash
        let hash = try await hashPhotoData(photoData)
        
        return hash
    }
    
    /// Get photo information for debugging
    func getPhotoInfo(from item: PhotosPickerItem) async throws -> (size: Int, format: String) {
        let data = try await extractPhotoData(from: item)
        
        // Try to determine format from data header
        let format = determinePhotoFormat(from: data)
        
        return (size: data.count, format: format)
    }
    
    /// Determine photo format from data header
    private func determinePhotoFormat(from data: Data) -> String {
        guard data.count >= 4 else { return "Unknown" }
        
        let header = data.prefix(4)
        
        // Check for JPEG
        if header.starts(with: [0xFF, 0xD8, 0xFF]) {
            return "JPEG"
        }
        
        // Check for PNG
        if header.starts(with: [0x89, 0x50, 0x4E, 0x47]) {
            return "PNG"
        }
        
        // Check for HEIC (ftyp box)
        if data.count >= 12 {
            let ftypRange = data.range(of: "ftyp".data(using: .ascii) ?? Data())
            if ftypRange != nil {
                return "HEIC"
            }
        }
        
        return "Unknown"
    }
} 