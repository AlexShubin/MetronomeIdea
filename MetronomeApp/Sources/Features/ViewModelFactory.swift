//
//  ViewModelFactory.swift
//  MetronomeApp
//
//  Created by Alex Shubin on 09.03.26.
//  Copyright © 2026 Alex Shubin. All rights reserved.
//

import MetronomeEngine
import SwiftUI

struct ViewModelFactory {
    @MainActor func makeMetronomeViewModel() -> MetronomeViewModel {
        MetronomeViewModel(metronome: MetronomeEngine.Dependencies.metronome)
    }

    @MainActor func makeSettingsViewModel() -> SettingsViewModel {
        SettingsViewModel()
    }
}

// MARK: - Environment

private struct ViewModelFactoryKey: EnvironmentKey {
    static let defaultValue = ViewModelFactory()
}

extension EnvironmentValues {
    var viewModelFactory: ViewModelFactory {
        get { self[ViewModelFactoryKey.self] }
        set { self[ViewModelFactoryKey.self] = newValue }
    }
}
