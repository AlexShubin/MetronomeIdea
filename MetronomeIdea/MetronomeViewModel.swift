//
//  MetronomeViewModel.swift
//  MetronomeIdea
//
//  Created by ashubin on 27.07.23.
//

import Foundation
import QuartzCore.CADisplayLink

enum MetronomeViewModelAction {
    case tempoChanged(tempo: Int)
    case play
    case stop
}

struct Beat: Identifiable, Equatable {
    let id: Int
    let highlighted: Bool
}

class MetronomeViewModel: ObservableObject {
    @Published var highlightedBeats: [Beat] = .initial
    @Published var tempo = 120

    private let metronome: MetronomeType

    private lazy var displayLink: CADisplayLink = {
        let displayLink = CADisplayLink(target: self, selector: #selector(updateHighlightedBeats))
        displayLink.add(to: .current, forMode: .default)
        return displayLink
    }()

    init(metronome: MetronomeType) {
        self.metronome = metronome
    }

    @objc private func updateHighlightedBeats() {
        let progress = metronome.currentProgressWithinBar
        highlightedBeats = [
            .init(id: 0, highlighted: progress > 0),
            .init(id: 1, highlighted: progress > 0.25),
            .init(id: 2, highlighted: progress > 0.5),
            .init(id: 3, highlighted: progress > 0.75)
        ]
    }

    func accept(action: MetronomeViewModelAction) {
        switch action {
        case .tempoChanged(let tempo):
            self.tempo = tempo
            if metronome.isPlaying {
                metronome.play(bpm: Double(tempo))
            }
        case .play:
            displayLink.isPaused = false
            metronome.play(bpm: Double(tempo))
        case .stop:
            metronome.stop()
            displayLink.isPaused = true
            highlightedBeats = .initial
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
