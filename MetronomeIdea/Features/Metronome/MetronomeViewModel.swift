//
//  MetronomeViewModel.swift
//  MetronomeIdea
//
//  Created by Alex Shubin on 27.07.23.
//  Copyright © 2023 Alex Shubin. All rights reserved.
//

import Combine
import Foundation

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

@Observable
class MetronomeViewModel {
    var highlightedBeats: [Beat] = .initial
    var tempo = 120
    var destination: MetronomeDestination?

    @ObservationIgnored private let useCase: MetronomeUseCaseType
    @ObservationIgnored private var cancellable: AnyCancellable?

    init(useCase: MetronomeUseCaseType) {
        self.useCase = useCase
    }

    func accept(action: MetronomeViewModelAction) {
        switch action {
        case .tempoChanged(let tempo):
            self.tempo = tempo
            useCase.changeTempo(to: Double(tempo))
        case .play:
            useCase.play(bpm: Double(tempo))
            startObservingProgress()
        case .stop:
            useCase.stop()
            cancellable = nil
            highlightedBeats = .initial
        case .settingsTapped:
            destination = .settings
        }
    }

    private func startObservingProgress() {
        cancellable = useCase.currentProgressWithinBar
            .sink { [weak self] progress in
                self?.highlightedBeats = [
                    .init(id: 0, highlighted: progress.value > 0),
                    .init(id: 1, highlighted: progress.value > 0.25),
                    .init(id: 2, highlighted: progress.value > 0.5),
                    .init(id: 3, highlighted: progress.value > 0.75)
                ]
            }
    }
}

private extension Array where Element == Beat {
    static let initial: Self = [
        .init(id: 0, highlighted: false),
        .init(id: 1, highlighted: false),
        .init(id: 2, highlighted: false),
        .init(id: 3, highlighted: false)
    ]
}
