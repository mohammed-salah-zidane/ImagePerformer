//
//  LoadingView.swift
//  Image Performer
//
//  Created by Mohamed Salah on 02/10/2024.
//

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
                    .foregroundColor(
                        colorScheme == .dark ? Color.white : Color.black
                    )

            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(colorScheme == .dark ? Color.black : Color.white)
    }
}

#Preview {
    LoadingView(showNoNetworkText: true)
}
