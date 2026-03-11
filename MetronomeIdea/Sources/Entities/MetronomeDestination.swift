//
//  MetronomeDestination.swift
//  MetronomeIdea
//
//  Created by Alex Shubin on 09.03.26.
//  Copyright © 2026 Alex Shubin. All rights reserved.
//

import Foundation

enum MetronomeDestination: Identifiable, Equatable {
    case settings

    var id: String {
        switch self {
        case .settings: "settings"
        }
    }
}
