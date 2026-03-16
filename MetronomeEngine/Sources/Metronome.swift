//
//  Metronome.swift
//  MetronomeEngine
//
//  Created by Alex Shubin on 09.03.26.
//  Copyright © 2026 Alex Shubin. All rights reserved.
//

public protocol MetronomeType: Actor {
    func play(bpm: Double)
    func stop()
    func changeTempo(to bpm: Double)

    var currentProgress: AsyncStream<ProgressWithinBar> { get }
}

public struct ProgressWithinBar: Sendable {
    public let value: Double
}

actor Metronome: MetronomeType {
    private let metronomeEngine: MetronomeEngineType
    private let displayLink: DisplayLinkTickerType

    private var barLength: Double = 0

    init(metronomeEngine: MetronomeEngineType, displayLink: DisplayLinkTickerType) {
        self.metronomeEngine = metronomeEngine
        self.displayLink = displayLink
    }

    var currentProgress: AsyncStream<ProgressWithinBar> {
        AsyncStream { continuation in
            let task = Task {
                for await _ in displayLink.ticks {
                    continuation.yield(progressWithinBar)
                }
            }
            continuation.onTermination = { _ in task.cancel() }
        }
    }

    private var progressWithinBar: ProgressWithinBar {
        guard barLength > 0 else { return ProgressWithinBar(value: 0) }
        return ProgressWithinBar(value: metronomeEngine.sampleTime
            .truncatingRemainder(dividingBy: barLength) / barLength)
    }

    func play(bpm: Double) {
        barLength = metronomeEngine.play(bpm: bpm)
        displayLink.resume()
    }

    func stop() {
        metronomeEngine.stop()
        displayLink.pause()
    }

    func changeTempo(to bpm: Double) {
        if metronomeEngine.isPlaying {
            play(bpm: bpm)
        }
    }
}
