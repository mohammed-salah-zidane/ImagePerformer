# Image Performer

A SwiftUI-based application demonstrating image loading with network connectivity handling, utilizing modern Swift development practices, adhering to SOLID principles, and ensuring testability and modularity.

---

## Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Architecture](#architecture)
- [Project Structure](#project-structure)
- [Components](#components)
  - [MainApp](#mainapp)
  - [ImageLoaderView](#imageloaderview)
  - [ImageLoaderViewModel](#imageloaderviewmodel)
  - [ImageLoaderViewModelBuilder](#imageloaderviewmodelbuilder)
  - [FetchImageUseCase](#fetchimageusecase)
  - [ImageRepository](#imagerepository)
  - [NetworkOperationPerformer](#networkoperationperformer)
  - [NetworkMonitor](#networkmonitor)
  - [LoadingView](#loadingview)
  - [LoadingState](#loadingstate)
- [Adherence to SOLID Principles](#adherence-to-solid-principles)
- [Testability and Modularity](#testability-and-modularity)
- [Running the Project](#running-the-project)
- [Conclusion](#conclusion)
- [License](#license)
  
---

## Overview

**Image Performer** is a SwiftUI application that showcases how to perform an image download operation with network connectivity checks and timeout handling. The app starts with a loading screen and transitions to displaying the downloaded image or an error message based on the result.

This project demonstrates clean code practices, adherence to SOLID principles, testability, and modularity, aligning with modern Swift development standards using **Swift 6** and **Xcode 16**.

---

## Features

- **Loading Screen**: Displays a loading screen upon app start.
- **Network Connectivity Check**: If the internet is not accessible within 0.5 seconds, displays a "No network connection" message.
- **Image Download with Timeout**: Performs an image download operation with a 2-second timeout.
- **Result Handling**: Displays the downloaded image upon success or an error message upon failure.
- **Modern Swift Features**: Utilizes `@Observable`, `@Observation`, and other modern Swift features.
- **Clean Architecture**: Follows a clean architecture with separation of concerns.
- **Testable and Modular**: The code is structured to be fully testable and modular.

---

## Architecture

The application follows a **Clean Architecture** approach, separating concerns into different layers:

- **Presentation Layer**: Contains UI components and ViewModels.
- **Domain Layer**: Includes business logic, use cases, and domain models.
- **Data Layer**: Handles data retrieval, network operations, and repositories.

This architecture promotes modularity, testability, and adherence to SOLID principles.

---

## Project Structure

```
Image Performer/
├── MainApp.swift
├── Presentation/
│   ├── Views/
│   │   ├── ImageLoaderView.swift
│   │   └── LoadingView.swift
│   └── ViewModels/
│       ├── ImageLoaderViewModel.swift
│       └── ImageLoaderViewModelBuilder.swift
├── Domain/
│   ├── UseCases/
│   │   └── FetchImageUseCase.swift
│   ├── Models/
│   │   └── LoadingState.swift
│   └── Protocols/
│       ├── ViewModelProtocol.swift
│       ├── FetchImageUseCaseProtocol.swift
│       ├── ImageRepositoryProtocol.swift
│       ├── NetworkMonitorProtocol.swift
│       └── NetworkOperationPerformerProtocol.swift
├── Data/
    ├── Repositories/
    │   └── ImageRepository.swift
    └── Network/
        ├── NetworkMonitor.swift
        └── NetworkOperationPerformer.swift

```

---

## Components

### MainApp

**File**: `MainApp.swift`

The entry point of the application, conforming to the `App` protocol. It initializes the `ImageLoaderViewModel` using the `ImageLoaderViewModelBuilder` and injects it into the `ImageLoaderView`.

```swift
import SwiftUI

@main
struct MainApp: App {
    var body: some Scene {
        WindowGroup {
            if let viewModel = ImageLoaderViewModelBuilder()
                .setImageURL(URL(string: "https://example.com/image.png")!)
                .build() {
                ImageLoaderView(viewModel: viewModel)
            } else {
                Text("Failed to build ViewModel")
            }
        }
    }
}
```

---

### ImageLoaderView

**File**: `ImageLoaderView.swift`

A SwiftUI view that displays different content based on the image loading state managed by the `ImageLoaderViewModel`.

```swift
import SwiftUI
import Observation

struct ImageLoaderView<ViewModel: ViewModelProtocol>: View {
    private var viewModel: ViewModel

    init(viewModel: ViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        Group {
            switch viewModel.state {
            case .idle:
                Color.clear
                    .onAppear {
                        viewModel.start()
                    }
            case .loading(let showNoNetworkText):
                LoadingView(showNoNetworkText: showNoNetworkText)
            case .success(let image):
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
            case .failure(let message):
                Text(message)
            }
        }
        .edgesIgnoringSafeArea(.all)
    }
}
```

---

### ImageLoaderViewModel

**File**: `ImageLoaderViewModel.swift`

An observable class responsible for managing the state of the image loading process. It uses the `FetchImageUseCase` to perform the image download operation.

```swift
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
            try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
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
```

---

### ImageLoaderViewModelBuilder

**File**: `ImageLoaderViewModelBuilder.swift`

A builder class that encapsulates the creation logic of `ImageLoaderViewModel` and its dependencies.

```swift
import Foundation

/// A builder class for creating instances of `ImageLoaderViewModel`.
class ImageLoaderViewModelBuilder {
    private var imageURL: URL?
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
        let imageRepository = ImageRepository(imageURL: imageURL)
        let networkMonitor = self.networkMonitor ?? NetworkMonitor()
        let networkOperationPerformer = NetworkOperationPerformer(networkMonitor: networkMonitor)
        let fetchImageUseCase = FetchImageUseCase(
            imageRepository: imageRepository,
            networkOperationPerformer: networkOperationPerformer
        )
        return ImageLoaderViewModel(
            fetchImageUseCase: fetchImageUseCase,
            networkMonitor: networkMonitor
        )
    }
}
```

---

### FetchImageUseCase

**File**: `FetchImageUseCase.swift`

A use case class that handles the logic of fetching an image using the `ImageRepository` and `NetworkOperationPerformer`.

```swift
import Foundation
import UIKit

/// A use case responsible for fetching an image using the repository and network operation performer.
class FetchImageUseCase: FetchImageUseCaseProtocol {
    private let imageRepository: ImageRepositoryProtocol
    private let networkOperationPerformer: NetworkOperationPerformerProtocol

    /// Initializes a new instance of `FetchImageUseCase`.
    ///
    /// - Parameters:
    ///   - imageRepository: The repository to fetch the image from.
    ///   - networkOperationPerformer: The network operation performer to handle network checks and timeouts.
    init(
        imageRepository: ImageRepositoryProtocol,
        networkOperationPerformer: NetworkOperationPerformerProtocol
    ) {
        self.imageRepository = imageRepository
        self.networkOperationPerformer = networkOperationPerformer
    }

    /// Executes the image fetching process.
    ///
    /// - Returns: A `Result` containing the fetched `UIImage` or an `Error`.
    func execute() async -> Result<UIImage, Error> {
        do {
            let image = try await networkOperationPerformer.perform(withinSeconds: 2) { [weak self] in
                guard let self = self else {
                    throw URLError(.cancelled)
                }
                return try await self.imageRepository.fetchImage()
            }

            guard let loadedImage = image else {
                return .failure(URLError(.timedOut))
            }

            return .success(loadedImage)

        } catch {
            return .failure(error)
        }
    }
}
```

---

### ImageRepository

**File**: `ImageRepository.swift`

A repository class responsible for fetching images from a given URL and caching them.

```swift
import Foundation
import UIKit

/// A repository responsible for fetching images from a specified URL.
class ImageRepository: ImageRepositoryProtocol {
    private let imageURL: URL
    private static let cache = NSCache<NSURL, UIImage>()

    /// Initializes a new instance of `ImageRepository`.
    ///
    /// - Parameter imageURL: The URL of the image to fetch.
    init(imageURL: URL) {
        self.imageURL = imageURL
    }

    /// Fetches the image from the specified URL.
    ///
    /// - Returns: The fetched `UIImage`.
    /// - Throws: An error if the image cannot be fetched or decoded.
    func fetchImage() async throws -> UIImage {
        if let cachedImage = Self.cache.object(forKey: imageURL as NSURL) {
            return cachedImage
        }

        let (data, _) = try await URLSession.shared.data(from: imageURL)
        guard let image = UIImage(data: data) else {
            throw URLError(.badServerResponse)
        }

        Self.cache.setObject(image, forKey: imageURL as NSURL)
        return image
    }
}
```

---

### NetworkOperationPerformer

**File**: `NetworkOperationPerformer.swift`

A class that performs network operations with network availability checks and timeout handling.

```swift
import Foundation

/// A class responsible for performing network operations with network availability checks and timeout handling.
class NetworkOperationPerformer: NetworkOperationPerformerProtocol {
    private let networkMonitor: NetworkMonitorProtocol

    /// Initializes a new instance of `NetworkOperationPerformer`.
    ///
    /// - Parameter networkMonitor: The network monitor to use for checking network connectivity.
    init(networkMonitor: NetworkMonitorProtocol = NetworkMonitor()) {
        self.networkMonitor = networkMonitor
    }

    /// Attempts to perform a network operation within the given timeout duration.
    /// If the network is not accessible within the timeout, the operation is not performed.
    ///
    /// - Parameters:
    ///   - timeoutDuration: The timeout duration in seconds.
    ///   - operation: The network operation to perform.
    /// - Returns: The result of the network operation, or `nil` if the network was not accessible within the timeout.
    /// - Throws: An error if the operation throws or if the task is cancelled.
    func perform<T>(
        withinSeconds timeoutDuration: TimeInterval,
        operation: @escaping () async throws -> T
    ) async throws -> T? {
        if Task.isCancelled {
            throw CancellationError()
        }

        if networkMonitor.isConnected {
            return try await operation()
        }

        let isConnected = await networkMonitor.waitForConnection(timeout: timeoutDuration)

        if isConnected {
            if Task.isCancelled {
                throw CancellationError()
            }
            return try await operation()
        } else {
            return nil
        }
    }
}
```

---

### NetworkMonitor

**File**: `NetworkMonitor.swift`

An actor class that monitors network connectivity status using `NWPathMonitor`.

```swift
import Foundation
import Network

/// An actor that monitors network connectivity status.
actor NetworkMonitor: NetworkMonitorProtocol {
    private let monitor: NWPathMonitor
    private var continuation: CheckedContinuation<Bool, Never>?
    private var isResolved = false

    /// Initializes a new instance of `NetworkMonitor` and starts monitoring.
    init() {
        self.monitor = NWPathMonitor()
        self.monitor.start(queue: DispatchQueue.global(qos: .background))
    }

    /// A nonisolated computed property indicating whether the network is currently connected.
    nonisolated var isConnected: Bool {
        monitor.currentPath.status == .satisfied
    }

    /// Waits for the network to become accessible within the specified timeout.
    ///
    /// - Parameter timeout: The maximum time to wait for network connectivity, in seconds.
    /// - Returns: `true` if the network became accessible within the timeout; otherwise, `false`.
    func waitForConnection(timeout: TimeInterval) async -> Bool {
        if isConnected {
            return true
        }

        isResolved = false

        return await withCheckedContinuation { continuation in
            self.continuation = continuation

            monitor.pathUpdateHandler = { [weak self] path in
                Task {
                    await self?.handlePathUpdate(status: path.status)
                }
            }

            Task {
                try? await Task.sleep(nanoseconds: UInt64(timeout * 1_000_000_000))
                await self.handleTimeout()
            }
        }
    }

    /// Handles network path updates and resumes the continuation if the network becomes accessible.
    ///
    /// - Parameter status: The current network path status.
    private func handlePathUpdate(status: NWPath.Status) async {
        if status == .satisfied && !isResolved {
            isResolved = true
            continuation?.resume(returning: true)
            continuation = nil
            monitor.pathUpdateHandler = nil
        }
    }

    /// Handles timeout by resuming the continuation if the network did not become accessible within the timeout.
    private func handleTimeout() async {
        if !isResolved {
            isResolved = true
            continuation?.resume(returning: false)
            continuation = nil
            monitor.pathUpdateHandler = nil
        }
    }

    deinit {
        monitor.cancel()
    }
}
```

---

### LoadingView

**File**: `LoadingView.swift`

A SwiftUI view that displays a loading indicator and an optional "No network connection" message.

```swift
import SwiftUI

/// A view that displays a loading indicator and an optional "No network connection" message.
struct LoadingView: View {
    let showNoNetworkText: Bool
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        VStack {
            ProgressView()
            if showNoNetworkText {
                Text("No network connection.")
                    .padding(.top, 8)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(colorScheme == .dark ? Color.black : Color.white)
    }
}
```

---

### LoadingState

**File**: `LoadingState.swift`

An enumeration representing the various states of the image loading process.

```swift
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
```

---

## Adherence to SOLID Principles

- **Single Responsibility Principle (SRP)**: Each class and struct has a single responsibility.
- **Open/Closed Principle (OCP)**: Classes are open for extension but closed for modification.
- **Liskov Substitution Principle (LSP)**: Components can be substituted with their abstractions without altering correctness.
- **Interface Segregation Principle (ISP)**: Interfaces are specific to client requirements, avoiding fat interfaces.
- **Dependency Inversion Principle (DIP)**: High-level modules depend on abstractions, not on concrete implementations.

---

## Testability and Modularity

- **Testability**: The use of protocols and dependency injection allows for mocking dependencies in unit tests.
- **Modularity**: The application is divided into clear layers and components, making it easy to maintain and extend.
- **Clean Architecture**: The separation of concerns promotes a clean architecture, facilitating scalability and testability.

---

## Running the Project

1. **Prerequisites**:
   - **Xcode 16** or later.
   - **Swift 6**.
   - **iOS 17** or later as the deployment target.

2. **Setup**:
   - Clone or download the repository.
   - Open `Image Performer.xcodeproj` in Xcode.
   - Replace the image URL in `MainApp.swift` with a valid image URL:

     ```swift
     .setImageURL(URL(string: "https://example.com/image.png")!)
     ```

3. **Build and Run**:
   - Select the desired simulator or connected device.
   - Build and run the project using Xcode.

---

## Conclusion

**Image Performer** demonstrates a robust, clean, and testable approach to building a SwiftUI application using modern Swift development practices available in **Swift 6** and **Xcode 16**. It adheres to SOLID principles, ensuring maintainability and scalability.

Feel free to explore the code, run the tests, and use this project as a reference for building modular and testable Swift applications.

---

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---
