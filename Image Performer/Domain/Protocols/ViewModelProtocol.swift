//
//  ViewModelProtocol.swift
//  Image Performer
//
//  Created by Mohamed Salah on 02/10/2024.
//

import Foundation
import Combine

/// A protocol defining the requirements for a view model managing image loading.
protocol ViewModelProtocol: ObservableObject {
    /// The current state of the image loading process.
    var state: LoadingState { get }
    
    /// Starts the image loading process.
    func start()
}
