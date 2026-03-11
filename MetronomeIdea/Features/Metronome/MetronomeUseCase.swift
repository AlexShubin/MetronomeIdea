//
//  MetronomeUseCase.swift
//  MetronomeIdea
//
//  Created by Alex Shubin on 09.03.26.
//  Copyright © 2026 Alex Shubin. All rights reserved.
//

import Combine

protocol MetronomeUseCaseType {
    func play(bpm: Double)
    func stop()
    func changeTempo(to bpm: Double)

    var currentProgressWithinBar: AnyPublisher<ProgressWithinBar, Never> { get }
}

class MetronomeUseCase: MetronomeUseCaseType {
    private let metronome: MetronomeType
    private let displayLink: DisplayLinkTickerType

    var currentProgressWithinBar: AnyPublisher<ProgressWithinBar, Never> {
        displayLink.ticks
            .map { [metronome] _ in metronome.currentProgressWithinBar }
            .eraseToAnyPublisher()
    }

    init(metronome: MetronomeType, displayLink: DisplayLinkTickerType) {
        self.metronome = metronome
        self.displayLink = displayLink
    }

    func play(bpm: Double) {
        metronome.play(bpm: bpm)
        displayLink.resume()
    }

    func stop() {
        metronome.stop()
        displayLink.pause()
    }

    func changeTempo(to bpm: Double) {
        if metronome.isPlaying {
            metronome.play(bpm: bpm)
        }
    }
}
