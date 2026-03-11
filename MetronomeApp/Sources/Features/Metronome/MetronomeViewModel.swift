//
//  MetronomeViewModel.swift
//  MetronomeApp
//
//  Created by Alex Shubin on 27.07.23.
//  Copyright © 2023 Alex Shubin. All rights reserved.
//

import Foundation
import Observation

enum MetronomeViewModelAction {
    case tempoChanged(tempo: Int)
    case play
    case stop
    case settingsTapped
}

struct Beat: Identifiable, Equatable {
    let id: Int
    let highlighted: Bool
}

enum MetronomeDestination: Identifiable, Equatable {
    case settings

    var id: String {
        switch self {
        case .settings: "settings"
        }
    }
}

@Observable
class MetronomeViewModel {
    var tempo = 120
    var destination: MetronomeDestination?

    @ObservationIgnored private let useCase: MetronomeUseCaseType

    init(useCase: MetronomeUseCaseType) {
        self.useCase = useCase
    }

    var highlightedBeats: [Beat] {
        let progress = useCase.currentProgress
        return [
            .init(id: 0, highlighted: progress.value > 0),
            .init(id: 1, highlighted: progress.value > 0.25),
            .init(id: 2, highlighted: progress.value > 0.5),
            .init(id: 3, highlighted: progress.value > 0.75)
        ]
    }

    func accept(action: MetronomeViewModelAction) {
        switch action {
        case .tempoChanged(let tempo):
            self.tempo = tempo
            useCase.changeTempo(to: Double(tempo))
        case .play:
            useCase.play(bpm: Double(tempo))
        case .stop:
            useCase.stop()
        case .settingsTapped:
            destination = .settings
        }
    }
}
