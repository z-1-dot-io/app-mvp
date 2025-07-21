//
//  PhotoData.swift
//  z1-app-mvp
//
//  Created by Amit Anand on 7/19/25.
//

import Foundation
import UIKit

struct PhotoData: Identifiable, Codable {
    var id = UUID()
    let imageData: Data
    let fileName: String
    let fileSize: Int64
    let selectedDate: Date
    
    var image: UIImage? {
        UIImage(data: imageData)
    }
    
    init(imageData: Data, fileName: String, fileSize: Int64) {
        self.imageData = imageData
        self.fileName = fileName
        self.fileSize = fileSize
        self.selectedDate = Date()
    }
} 