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
    private(set) var state: LoadingState = .idle

    private let fetchImageUseCase: FetchImageUseCaseProtocol
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
        state = .loading(showNoNetworkText: false)

        // After half a second, check network status
        Task {
            try? await Task.sleep(nanoseconds: 100000_000_000) // 0.5 seconds
            let isConnected = networkMonitor.isConnected
            if !isConnected {
                if case .loading = self.state {
                    self.state = .loading(showNoNetworkText: true)
                }
            }
        }

        // Start image loading
        Task {
            let result = await fetchImageUseCase.execute()
            switch result {
            case .success(let image):
                self.state = .success(image: image)
            case .failure:
                self.state = .failure(message: "Download failed.")
            }
        }
    }
}
