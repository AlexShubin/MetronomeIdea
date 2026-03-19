//
//  MetronomeViewModel.swift
//  MetronomeApp
//
//  Created by Alex Shubin on 27.07.23.
//  Copyright © 2023 Alex Shubin. All rights reserved.
//

import Foundation
import Observation
import MetronomeEngine

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

@MainActor
protocol MetronomeViewModelType: Observable {
    var tempo: Int { get }
    var highlightedBeats: [Beat] { get }
    var destination: MetronomeDestination? { get set }
    func accept(action: MetronomeViewModelAction)
}

@MainActor @Observable
class MetronomeViewModel: MetronomeViewModelType {
    private(set) var tempo = 120
    private(set) var highlightedBeats: [Beat] = .initial

    var destination: MetronomeDestination?

    @ObservationIgnored private let metronome: MetronomeType
    @ObservationIgnored private var observationTask: Task<Void, Never>?

    init(metronome: MetronomeType) {
        self.metronome = metronome
        observationTask = Task { [weak self, metronome] in
            for await state in await metronome.metronomeStateStream {
                guard !Task.isCancelled else { break }
                self?.tempo = Int(state.tempo)
                self?.highlightedBeats = Self.beats(from: state)
            }
        }
    }

    deinit {
        observationTask?.cancel()
    }

    func accept(action: MetronomeViewModelAction) {
        switch action {
        case .tempoChanged(let tempo):
            Task { await metronome.changeTempo(to: Double(tempo)) }
        case .play:
            Task { await metronome.play() }
        case .stop:
            Task { await metronome.stop() }
        case .settingsTapped:
            destination = .settings
        }
    }

    private static func beats(from state: MetronomeState) -> [Beat] {
        guard state.isPlaying else { return .initial }
        return [
            .init(id: 0, highlighted: (0...0.25).contains(state.progressWithinBar)),
            .init(id: 1, highlighted: (0.25...0.5).contains(state.progressWithinBar)),
            .init(id: 2, highlighted: (0.5...0.75).contains(state.progressWithinBar)),
            .init(id: 3, highlighted: (0.75...1).contains(state.progressWithinBar)),
        ]
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
