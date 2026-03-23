//
//  MetronomeTests.swift
//  MetronomeEngineTests
//
//  Created by Alex Shubin on 14.03.26.
//  Copyright © 2026 Alex Shubin. All rights reserved.
//

import Testing
@testable import MetronomeEngine

@Suite
struct MetronomeTests {
    let mockEngine: MockMetronomeEngine
    let mockDisplayLink: MockDisplayLinkTicker

    let sut: MetronomeType

    init() {
        mockEngine = .init()
        mockDisplayLink = .init()

        sut = Metronome(metronomeEngine: mockEngine,
                        displayLink: mockDisplayLink)
    }

    @Test func initialState() async {
        var iterator = await sut.metronomeStateStream.makeAsyncIterator()
        let state = await iterator.next()

        #expect(state?.tempo == 120)
        #expect(state?.isPlaying == false)
        #expect(state?.progressWithinBar == 0)
    }

    @Test func play_setsIsPlayingAndStartsEngine() async {
        var iterator = await sut.metronomeStateStream.makeAsyncIterator()
        _ = await iterator.next() // consume initial

        await sut.play()
        let state = await iterator.next()

        #expect(state?.isPlaying == true)
        #expect(mockEngine.calls == [
            .play(bpm: 120)
        ])
        #expect(mockDisplayLink.calls == [
            .resume
        ])
    }

    @Test func stop_setsIsNotPlayingAndStopsEngine() async {
        var iterator = await sut.metronomeStateStream.makeAsyncIterator()
        _ = await iterator.next() // consume initial

        await sut.play()
        _ = await iterator.next()

        await sut.stop()
        let state = await iterator.next()

        #expect(state?.isPlaying == false)
        #expect(mockEngine.calls == [
            .play(bpm: 120), .stop
        ])
        #expect(mockDisplayLink.calls == [
            .resume, .pause
        ])
    }

    @Test func changeTempo_updatesTempoInState() async {
        var iterator = await sut.metronomeStateStream.makeAsyncIterator()
        _ = await iterator.next() // consume initial

        await sut.changeTempo(to: 180)
        let state = await iterator.next()

        #expect(state?.tempo == 180)
    }

    @Test func changeTempo_whilePlaying_restartsEngine() async {
        await sut.play()

        await sut.changeTempo(to: 180)

        #expect(mockEngine.calls == [
            .play(bpm: 120), .play(bpm: 180)
        ])
    }

    @Test func changeTempo_whileStopped_doesNotRestartEngine() async {
        await sut.changeTempo(to: 180)

        #expect(mockEngine.calls == [])
    }

    @Test func stateStream_emitsInitialState() async {
        var iterator = await sut.metronomeStateStream.makeAsyncIterator()

        let first = await iterator.next()

        #expect(first?.tempo == 120)
        #expect(first?.isPlaying == false)
    }

    @Test func stateStream_emitsOnPlay() async {
        var iterator = await sut.metronomeStateStream.makeAsyncIterator()
        _ = await iterator.next() // consume initial

        await sut.play()
        let state = await iterator.next()

        #expect(state?.isPlaying == true)
    }

    @Test func progressUpdates_onTick() async {
        mockEngine.stubbedSampleTime = 50
        mockEngine.stubbedBarLength = 100

        var iterator = await sut.metronomeStateStream.makeAsyncIterator()
        _ = await iterator.next() // consume initial

        await sut.play()
        _ = await iterator.next()

        mockDisplayLink.sendTick()
        let state = await iterator.next()

        #expect(state?.progressWithinBar == 0.5)
    }
}

// MARK: - Mocks

final class MockMetronomeEngine: MetronomeEngineType, @unchecked Sendable {

    enum Call: Equatable {
        case play(bpm: Double)
        case stop
    }
    // Safety: only mutated from the Metronome actor's isolation in tests.
    var calls = [Call]()
    var stubbedBarLength: Double = 100
    var stubbedSampleTime: Double = 0

    func play(bpm: Double) -> BarLength {
        calls.append(.play(bpm: bpm))
        return stubbedBarLength
    }

    func stop() {
        calls.append(.stop)
    }

    var sampleTime: Double {
        return stubbedSampleTime
    }
}

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
