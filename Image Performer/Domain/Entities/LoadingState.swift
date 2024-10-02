//
//  LoadingState.swift
//  Image Performer
//
//  Created by Mohamed Salah on 02/10/2024.
//

import UIKit

/// An enumeration representing the various states of the image loading process.
enum LoadingState: Equatable {
    /// The initial idle state.
    case idle
    /// The loading state, optionally showing a "No network connection" text.
    case loading(showNoNetworkText: Bool)
    /// The success state with the loaded image.
    case success(image: UIImage)
    /// The failure state with an error message.
    case failure(message: String)
}
