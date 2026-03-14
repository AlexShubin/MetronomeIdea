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
        Text("Settings")
    }
}

#Preview {
    @Previewable @State var viewModel: SettingsViewModelType = {
        @MainActor @Observable
        class PreviewSettingsViewModel: SettingsViewModelType {}
        return PreviewSettingsViewModel()
    }()
    SettingsView(viewModel: viewModel)
}
