//
//  ImageUploadService.swift
//  AIChatCourse
//
//  Created by Dmitro Kryzhanovsky on 17.01.2026.
//

import SwiftUI
import Foundation

protocol ImageUploadService: Sendable {
    func uploadImage(image: UIImage, path: String) async throws -> URL
}
