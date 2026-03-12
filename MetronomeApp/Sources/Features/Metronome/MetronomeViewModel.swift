//
//  MetronomeViewModel.swift
//  MetronomeApp
//
//  Created by Alex Shubin on 27.07.23.
//  Copyright © 2023 Alex Shubin. All rights reserved.
//

import Combine
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
    private(set) var tempo = 120
    private(set) var highlightedBeats: [Beat] = .initial

    var destination: MetronomeDestination?

    @ObservationIgnored private let useCase: MetronomeUseCaseType
    @ObservationIgnored private var progressCancellable: AnyCancellable?

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
            startObserving()
        case .stop:
            useCase.stop()
            progressCancellable = nil
            highlightedBeats = .initial
        case .settingsTapped:
            destination = .settings
        }
    }

    private func startObserving() {
        progressCancellable = useCase.currentProgress
            .receive(on: DispatchQueue.main)
            .sink { [weak self] progress in
                self?.highlightedBeats = [
                    .init(id: 0, highlighted: progress.value > 0),
                    .init(id: 1, highlighted: progress.value > 0.25),
                    .init(id: 2, highlighted: progress.value > 0.5),
                    .init(id: 3, highlighted: progress.value > 0.75),
                ]
            }
    }
}

private extension Array where Element == Beat {
    static let initial: Self = [
        .init(id: 0, highlighted: false),
        .init(id: 1, highlighted: false),
        .init(id: 2, highlighted: false),
        .init(id: 3, highlighted: false),
    ]
}
