//
//  ViewModelFactory.swift
//  MetronomeApp
//
//  Created by Alex Shubin on 09.03.26.
//  Copyright © 2026 Alex Shubin. All rights reserved.
//

import MetronomeEngine
import SwiftUI

struct ViewModelFactory: @unchecked Sendable {
    let metronomeShared = Metronome()
    let displayLinkTickerShared = DisplayLinkTicker()

    @MainActor func makeMetronomeViewModel() -> MetronomeViewModel {
        MetronomeViewModel(useCase: MetronomeUseCase(metronome: metronomeShared,
                                                     displayLink: displayLinkTickerShared))
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
