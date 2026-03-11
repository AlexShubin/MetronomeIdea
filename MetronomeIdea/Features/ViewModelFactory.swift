//
//  ViewModelFactory.swift
//  MetronomeIdea
//
//  Created by Alex Shubin on 09.03.26.
//  Copyright © 2026 Alex Shubin. All rights reserved.
//

import SwiftUI

struct ViewModelFactory {
    let metronomeShared: MetronomeType = Metronome(
        mainClickFile: Bundle.main.url(
            forResource: "Low", withExtension: "wav"
        )!,
        accentedClickFile: Bundle.main.url(
            forResource: "High", withExtension: "wav"
        )!
    )
    let displayLinkTickerShared: DisplayLinkTickerType = DisplayLinkTicker()

    func makeMetronomeViewModel() -> MetronomeViewModel {
        MetronomeViewModel(useCase: MetronomeUseCase(metronome: metronomeShared,
                                                     displayLink: displayLinkTickerShared))
    }

    func makeSettingsViewModel() -> SettingsViewModel {
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
