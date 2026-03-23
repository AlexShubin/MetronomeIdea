//
//  MockDisplayLinkTicker.swift
//  MetronomeEngineTests
//
//  Created by Alex Shubin on 14.03.26.
//  Copyright © 2026 Alex Shubin. All rights reserved.
//

@testable import MetronomeEngine

final class MockDisplayLinkTicker: DisplayLinkTickerType, @unchecked Sendable {
    enum Call: Equatable {
        case pause
        case resume
    }
    // Safety: only mutated from the Metronome actor's isolation in tests.
    var calls = [Call]()

    private var continuation: AsyncStream<Void>.Continuation?
    private let _ticks: AsyncStream<Void>

    init() {
        let (stream, continuation) = AsyncStream<Void>.makeStream()
        _ticks = stream
        self.continuation = continuation
    }

    var ticks: AsyncStream<Void> { _ticks }

    func pause() {
        calls.append(.pause)
    }

    func resume() {
        calls.append(.resume)
    }

    func sendTick() {
        continuation?.yield()
    }
}
