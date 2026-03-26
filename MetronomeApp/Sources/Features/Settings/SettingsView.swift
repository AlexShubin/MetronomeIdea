//
//  SettingsView.swift
//  MetronomeApp
//
//  Created by Alex Shubin on 09.03.26.
//  Copyright © 2026 Alex Shubin. All rights reserved.
//

import SwiftUI

struct SettingsView: View {
    @State var viewModel: SettingsViewModelType

    var body: some View {
        Text("🚧 Work in progress 🚧")
    }
}

// MARK: - Preview

@MainActor @Observable
private class PreviewSettingsViewModel: SettingsViewModelType {}

#Preview {
    SettingsView(viewModel: PreviewSettingsViewModel())
}
