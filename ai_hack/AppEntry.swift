//
//  NTUiOSClubLLMApp.swift
//  NTUiOSClubLLM
//
//  Created by Jane on 2025/2/22.
//

import SwiftUI

@main
struct ai_hack: App {
    @StateObject private var model = PredictionModel()
    var body: some Scene {
        WindowGroup {
            AppEntry().environment(\.openRouter, .shared).environmentObject(model)
        }
    }
}
