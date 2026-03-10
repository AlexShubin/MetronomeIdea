//
//  MetronomeViewModel.swift
//  MetronomeIdea
//
//  Created by Alex Shubin on 27.07.23.
//  Copyright © 2023 Alex Shubin. All rights reserved.
//

import Foundation

enum MetronomeViewModelAction {
    case tempoChanged(tempo: Int)
    case play
    case stop
}

struct Beat: Identifiable, Equatable {
    let id: Int
    let highlighted: Bool
}

@Observable
@MainActor
class MetronomeViewModel {
    var highlightedBeats: [Beat] = .initial
    var tempo = 120

    @ObservationIgnored private let useCase: MetronomeUseCaseType
    @ObservationIgnored private var progressTask: Task<Void, Never>?

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
            progressTask?.cancel()
            progressTask = nil
            highlightedBeats = .initial
        }
    }

    private func startObservingProgress() {
        progressTask?.cancel()
        progressTask = Task { [weak self] in
            guard let self else { return }
            for await progress in useCase.currentProgressWithinBar {
                highlightedBeats = [
                    .init(id: 0, highlighted: progress.value > 0),
                    .init(id: 1, highlighted: progress.value > 0.25),
                    .init(id: 2, highlighted: progress.value > 0.5),
                    .init(id: 3, highlighted: progress.value > 0.75)
                ]
            }
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
