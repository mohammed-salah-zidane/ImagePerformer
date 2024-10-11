//
//  ImageLoaderViewModelBuilder.swift
//  Image Performer
//
//  Created by Mohamed Salah on 02/10/2024.
//

import Foundation

/// A builder class for creating instances of `ImageLoaderViewModel`.
class ImageLoaderViewModelBuilder {
    // The URL of the image to load.
    private var imageURL: URL?
    // A custom network monitor, if any.
    private var networkMonitor: NetworkMonitorProtocol?

    /// Sets the image URL for the view model.
    ///
    /// - Parameter url: The URL of the image to load.
    /// - Returns: The builder instance for chaining.
    func setImageURL(_ url: URL) -> Self {
        self.imageURL = url
        return self
    }

    /// Sets the network monitor for the view model.
    ///
    /// - Parameter monitor: A custom network monitor.
    /// - Returns: The builder instance for chaining.
    func setNetworkMonitor(_ monitor: NetworkMonitorProtocol) -> Self {
        self.networkMonitor = monitor
        return self
    }

    /// Builds and returns an instance of `ImageLoaderViewModel`.
    ///
    /// - Returns: An optional `ImageLoaderViewModel` instance.
    @MainActor func build() -> ImageLoaderViewModel? {
        guard let imageURL = imageURL else { return nil }
        // Create the image repository with the provided URL.
        let imageRepository = ImageRepository(imageURL: imageURL)
        // Use the provided network monitor or create a default one.
        let networkMonitor = self.networkMonitor ?? NetworkMonitor()
        // Create the network operation performer with the network monitor.
        let networkOperationPerformer = NetworkOperationPerformer(networkMonitor: networkMonitor)
        // Create the fetch image use case with the repository and operation performer.
        let fetchImageUseCase = FetchImageUseCase(
            imageRepository: imageRepository,
            networkOperationPerformer: networkOperationPerformer
        )
        // Build and return the ImageLoaderViewModel.
        return ImageLoaderViewModel(
            fetchImageUseCase: fetchImageUseCase,
            networkMonitor: networkMonitor
        )
    }
}
