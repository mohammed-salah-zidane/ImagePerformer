//
//  FetchImageUseCaseProtocol.swift
//  Image Performer
//
//  Created by Mohamed Salah on 02/10/2024.
//

import Foundation
import UIKit

protocol FetchImageUseCaseProtocol {
    func execute() async -> Result<UIImage, Error>
}
