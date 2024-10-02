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
            if let viewModel = ImageLoaderViewModelBuilder()
                .setImageURL(URL(string: "https://img-cdn.pixlr.com/image-generator/history/65bb506dcb310754719cf81f/ede935de-1138-4f66-8ed7-44bd16efc709/medium.webp")!)
                .build() {
                ImageLoaderView(viewModel: viewModel)
            } else {
                Text("Failed to build ViewModel")
            }
        }
    }
}
