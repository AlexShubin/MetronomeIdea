//
//  MetronomeUseCase.swift
//  MetronomeApp
//
//  Created by Alex Shubin on 09.03.26.
//  Copyright © 2026 Alex Shubin. All rights reserved.
//

import MetronomeEngine

struct ProgressWithinBar {
    let value: Double
}

protocol MetronomeUseCaseType {
    func play(bpm: Double)
    func stop()
    func changeTempo(to bpm: Double)

    var currentProgress: AsyncStream<ProgressWithinBar> { get }
}

class MetronomeUseCase: MetronomeUseCaseType {
    private let metronome: MetronomeType
    private let displayLink: DisplayLinkTickerType

    init(metronome: MetronomeType, displayLink: DisplayLinkTickerType) {
        self.metronome = metronome
        self.displayLink = displayLink
    }

    var currentProgress: AsyncStream<ProgressWithinBar> {
        return AsyncStream { continuation in
            let task = Task {
                for await _ in displayLink.ticks {
                    continuation.yield(ProgressWithinBar(value: metronome.currentProgressWithinBar))
                }
                continuation.finish()
            }
            continuation.onTermination = { _ in task.cancel() }
        }
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

