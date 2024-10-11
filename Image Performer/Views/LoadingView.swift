//
//  LoadingView.swift
//  Image Performer
//
//  Created by Mohamed Salah on 02/10/2024.
//

import SwiftUI

/// A view that displays a loading indicator and an optional "No network connection" message.
struct LoadingView: View {
    // A flag indicating whether to show the "No network connection" message.
    let showNoNetworkText: Bool
    // Access to the current color scheme (light or dark mode).
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        VStack {
            // Display a progress indicator.
            ProgressView()
            if showNoNetworkText {
                // If the flag is set, display the "No network connection." message.
                Text("No network connection.")
                    .padding(.top, 8)
                    .foregroundColor(
                        colorScheme == .dark ? Color.white : Color.black
                    )
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(colorScheme == .dark ? Color.black : Color.white)
    }
}
