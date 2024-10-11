//
//  ImageLoaderViewModel.swift
//  Image Performer
//
//  Created by Mohamed Salah on 02/10/2024.
//

import Foundation
import UIKit
import Observation

/// The view model responsible for managing the state of the image loading process.
@Observable
class ImageLoaderViewModel: ViewModelProtocol {
    /// The current state of the image loading process.
    private(set) var state: LoadingState = .idle

    // The use case for fetching the image.
    private let fetchImageUseCase: FetchImageUseCaseProtocol
    // The network monitor for checking connectivity.
    private let networkMonitor: NetworkMonitorProtocol

    /// Initializes a new instance of `ImageLoaderViewModel`.
    ///
    /// - Parameters:
    ///   - fetchImageUseCase: The use case for fetching the image.
    ///   - networkMonitor: The network monitor for checking connectivity.
    init(
        fetchImageUseCase: FetchImageUseCaseProtocol,
        networkMonitor: NetworkMonitorProtocol
    ) {
        self.fetchImageUseCase = fetchImageUseCase
        self.networkMonitor = networkMonitor
    }

    /// Starts the image loading process.
    func start() {
        // Set the initial state to loading without the "No network connection" message.
        state = .loading(showNoNetworkText: false)

        // After half a second, check network status.
        Task {
            try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
            let isConnected = networkMonitor.isConnected
            if !isConnected {
                if case .loading = self.state {
                    // Update the state to show the "No network connection" message.
                    self.state = .loading(showNoNetworkText: true)
                }
            }
        }

        // Start the image loading task.
        Task {
            let result = await fetchImageUseCase.execute()
            switch result {
            case .success(let image):
                // Update the state to success with the loaded image.
                self.state = .success(image: image)
            case .failure:
                // Update the state to failure with an error message.
                self.state = .failure(message: "Download failed.")
            }
        }
    }
}
