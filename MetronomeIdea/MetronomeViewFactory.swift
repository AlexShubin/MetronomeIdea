//
//  MetronomeViewFactory.swift
//  MetronomeIdea
//
//  Created by Alex Shubin on 09.03.26.
//  Copyright © 2026 Alex Shubin. All rights reserved.
//

protocol MetronomeViewFactoryType {
    func makeSettingsViewModel() -> SettingsViewModel
}

struct MetronomeViewFactory: MetronomeViewFactoryType {
    func makeSettingsViewModel() -> SettingsViewModel {
        SettingsViewModel()
    }
}
