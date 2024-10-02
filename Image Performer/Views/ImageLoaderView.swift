//
//  ImageLoaderView.swift
//
//  Created by Mohamed Salah on 02/10/2024.
//

import SwiftUI
import Observation

/// A view that displays different content based on the image loading state.
struct ImageLoaderView<ViewModel: ViewModelProtocol>: View {
    private var viewModel: ViewModel

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
                Color.clear
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
        .onAppear {
            viewModel.start()
        }
    }
}
