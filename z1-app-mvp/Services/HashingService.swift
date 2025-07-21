//
//  HashingService.swift
//  z1-app-mvp
//
//  Created by Amit Anand on 7/19/25.
//

import Foundation
import PhotosUI

protocol HashingService {
    func hash(photo: PhotosPickerItem) async throws -> String
} 