//
//  ImageLoaderView.swift
//  Image Performer
//
//  Created by Mohamed Salah on 02/10/2024.
//

import SwiftUI
import Observation

/// A view that displays different content based on the image loading state.
struct ImageLoaderView<ViewModel: ViewModelProtocol>: View {
    // The observed view model managing the image loading state.
    @ObservedObject private var viewModel: ViewModel

    /// Initializes a new instance of `ImageLoaderView`.
    ///
    /// - Parameter viewModel: The view model managing the image loading state.
    init(viewModel: ViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        Group {
            switch viewModel.state {
            case .idle:
                // Display a clear color when idle.
                Color.clear
            case .loading(let showNoNetworkText):
                // Display the loading view, passing the flag for showing the "No network connection" message.
                LoadingView(showNoNetworkText: showNoNetworkText)
            case .success(let image):
                // Display the loaded image.
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
            case .failure(let message):
                // Display the failure message.
                Text(message)
            }
        }
        .edgesIgnoringSafeArea(.all)
        .onAppear {
            // Start the image loading process when the view appears.
            viewModel.start()
        }
    }
}
