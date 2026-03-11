//
//  MetronomeUseCase.swift
//  MetronomeIdea
//
//  Created by Alex Shubin on 09.03.26.
//  Copyright © 2026 Alex Shubin. All rights reserved.
//

import Observation

protocol MetronomeUseCaseType {
    func play(bpm: Double)
    func stop()
    func changeTempo(to bpm: Double)

    var currentProgress: ProgressWithinBar { get }
}

@Observable
class MetronomeUseCase: MetronomeUseCaseType {
    @ObservationIgnored private let metronome: MetronomeType
    @ObservationIgnored private let displayLink: DisplayLinkTickerType
    @ObservationIgnored private var tickTask: Task<Void, Never>?

    private(set) var currentProgress = ProgressWithinBar(value: 0)

    init(metronome: MetronomeType, displayLink: DisplayLinkTickerType) {
        self.metronome = metronome
        self.displayLink = displayLink
    }

    func play(bpm: Double) {
        metronome.play(bpm: bpm)
        displayLink.resume()
        startObserving()
    }

    func stop() {
        metronome.stop()
        displayLink.pause()
        tickTask?.cancel()
        tickTask = nil
        currentProgress = ProgressWithinBar(value: 0)
    }

    func changeTempo(to bpm: Double) {
        if metronome.isPlaying {
            metronome.play(bpm: bpm)
        }
    }

    private func startObserving() {
        tickTask?.cancel()
        tickTask = Task { [weak self, displayLink, metronome] in
            for await _ in displayLink.ticks {
                self?.currentProgress = ProgressWithinBar(value: metronome.currentProgressWithinBar)
            }
        }
    }
}
