//
//  MetronomeUseCase.swift
//  MetronomeApp
//
//  Created by Alex Shubin on 09.03.26.
//  Copyright © 2026 Alex Shubin. All rights reserved.
//

import Combine
import MetronomeEngine

struct ProgressWithinBar {
    let value: Double
}

protocol MetronomeUseCaseType {
    func play(bpm: Double)
    func stop()
    func changeTempo(to bpm: Double)

    var currentProgress: AnyPublisher<ProgressWithinBar, Never> { get }
}

class MetronomeUseCase: MetronomeUseCaseType {
    private let metronome: MetronomeType
    private let displayLink: DisplayLinkTickerType

    init(metronome: MetronomeType, displayLink: DisplayLinkTickerType) {
        self.metronome = metronome
        self.displayLink = displayLink
    }

    var currentProgress: AnyPublisher<ProgressWithinBar, Never> {
        displayLink.ticks
            .map { [metronome] _ in
                ProgressWithinBar(value: metronome.currentProgressWithinBar)
            }
            .eraseToAnyPublisher()
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

