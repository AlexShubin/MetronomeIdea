//
//  SettingsViewModel.swift
//  MetronomeApp
//
//  Created by Alex Shubin on 09.03.26.
//  Copyright © 2026 Alex Shubin. All rights reserved.
//

import Foundation

@MainActor
protocol SettingsViewModelType: Observable {}

@MainActor @Observable
class SettingsViewModel: SettingsViewModelType {}
