//
//  AppEntryManual.swift
//  ai_hack
//
//  Created by 陳致和 on 2025/4/25.
//

import SwiftUI

struct AppEntry: View {
    @State private var showMain = false

    var body: some View {
        Group {
            if showMain {
                MainScreen()
            } else {
                WelcomeView(showMain: $showMain)
            }
        }
    }
}

#Preview {
    AppEntry().environment(\.openRouter, .shared).environmentObject(PredictionModel())
}
