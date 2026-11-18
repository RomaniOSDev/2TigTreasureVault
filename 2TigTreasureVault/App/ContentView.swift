//
//  ContentView.swift
//  2TigTreasureVault
//
//  Created by Roman on 11/10/26.
//

import Combine
import SwiftUI
import UIKit

/// Root of the SwiftUI side: owns the game state and decides between the intro and the game.
struct ContentView: View {
    @State private var store = VaultStore()
    @State private var settings = AppSettings()

    private let ticker = Timer.publish(every: 0.25, on: .main, in: .common).autoconnect()

    var body: some View {
        Group {
            if settings.hasSeenOnboarding {
                MainShellView()
                    .transition(.opacity)
            } else {
                OnboardingView {
                    settings.hasSeenOnboarding = true
                }
                .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.35), value: settings.hasSeenOnboarding)
        .environment(store)
        .environment(settings)
        .preferredColorScheme(.dark)
        .onReceive(ticker) { now in
            store.tick(now: now)
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.didEnterBackgroundNotification)) { _ in
            store.persist()
        }
    }
}

#Preview {
    ContentView()
}
