//
//  MainApp.swift
//  Image Performer
//
//  Created by Mohamed Salah on 02/10/2024.
//

import SwiftUI

@main
struct MainApp: App {
    var body: some Scene {
        WindowGroup {
            // Attempt to build the ImageLoaderViewModel using the builder
            if let viewModel = ImageLoaderViewModelBuilder()
                .setImageURL(URL(string: "https://img-cdn.pixlr.com/image-generator/history/65bb506dcb310754719cf81f/ede935de-1138-4f66-8ed7-44bd16efc709/medium.webp")!) // Replace with a valid image URL
                .build() {
                // Pass the view model to the ImageLoaderView
                ImageLoaderView(viewModel: viewModel)
            } else {
                // Display an error message if the view model couldn't be built
                Text("Failed to build ViewModel")
            }
        }
    }
}
