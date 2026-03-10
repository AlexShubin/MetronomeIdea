//
//  MetronomeUseCase.swift
//  MetronomeIdea
//
//  Created by Alex Shubin on 09.03.26.
//  Copyright © 2026 Alex Shubin. All rights reserved.
//

protocol MetronomeUseCaseType {
    func play(bpm: Double)
    func stop()
    func changeTempo(to bpm: Double)

    var currentProgressWithinBar: AsyncStream<ProgressWithinBar> { get }
}

struct ProgressWithinBar {
    let value: Double
}

class MetronomeUseCase: MetronomeUseCaseType {
    private let metronome: MetronomeType
    private let displayLink: DisplayLinkStreamType

    var currentProgressWithinBar: AsyncStream<ProgressWithinBar> {
        AsyncStream { [displayLink, metronome] continuation in
            Task {
                for await _ in displayLink.ticks {
                    continuation.yield(ProgressWithinBar(value: metronome.currentProgressWithinBar))
                }
                continuation.finish()
            }
        }
    }

    init(metronome: MetronomeType, displayLink: DisplayLinkStreamType) {
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

