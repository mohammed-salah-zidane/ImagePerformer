//
//  ImageRepositoryProtocol.swift
//  Image Performer
//
//  Created by Mohamed Salah on 02/10/2024.
//

import Foundation
import UIKit

protocol ImageRepositoryProtocol {
    func fetchImage() async throws -> UIImage
}
