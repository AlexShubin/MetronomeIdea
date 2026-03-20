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
    let mockEngine = MockMetronomeEngine()
    let mockDisplayLink = MockDisplayLinkTicker()

    func makeSUT() -> Metronome {
        Metronome(metronomeEngine: mockEngine, displayLink: mockDisplayLink)
    }

    @Test func initialState() async {
        let sut = makeSUT()
        let state = await sut.metronomeState
        #expect(state.tempo == 120)
        #expect(state.isPlaying == false)
        #expect(state.progressWithinBar == 0)
    }

    @Test func play_setsIsPlayingAndStartsEngine() async {
        let sut = makeSUT()

        await sut.play()

        let state = await sut.metronomeState
        #expect(state.isPlaying == true)
        #expect(mockEngine.playCallCount == 1)
        #expect(mockEngine.lastPlayedBPM == 120)
        #expect(mockDisplayLink.resumeCallCount == 1)
    }

    @Test func stop_setsIsNotPlayingAndStopsEngine() async {
        let sut = makeSUT()
        await sut.play()

        await sut.stop()

        let state = await sut.metronomeState
        #expect(state.isPlaying == false)
        #expect(mockEngine.stopCallCount == 1)
        #expect(mockDisplayLink.pauseCallCount == 1)
    }

    @Test func changeTempo_updatesTempoInState() async {
        let sut = makeSUT()

        await sut.changeTempo(to: 180)

        let state = await sut.metronomeState
        #expect(state.tempo == 180)
    }

    @Test func changeTempo_whilePlaying_restartsEngine() async {
        let sut = makeSUT()
        await sut.play()

        await sut.changeTempo(to: 180)

        #expect(mockEngine.playCallCount == 2)
        #expect(mockEngine.lastPlayedBPM == 180)
    }

    @Test func changeTempo_whileStopped_doesNotRestartEngine() async {
        let sut = makeSUT()

        await sut.changeTempo(to: 180)

        #expect(mockEngine.playCallCount == 0)
    }

    @Test func stateStream_emitsInitialState() async {
        let sut = makeSUT()
        var iterator = await sut.metronomeStateStream.makeAsyncIterator()

        let first = await iterator.next()

        #expect(first?.tempo == 120)
        #expect(first?.isPlaying == false)
    }

    @Test func stateStream_emitsOnPlay() async {
        let sut = makeSUT()
        var iterator = await sut.metronomeStateStream.makeAsyncIterator()
        _ = await iterator.next() // consume initial

        await sut.play()
        let state = await iterator.next()

        #expect(state?.isPlaying == true)
    }

    @Test func progressUpdates_onTick() async {
        mockEngine.stubbedSampleTime = 50
        mockEngine.stubbedBarLength = 100
        let sut = makeSUT()
        var iterator = await sut.metronomeStateStream.makeAsyncIterator()
        _ = await iterator.next() // consume initial

        await sut.play()
        _ = await iterator.next() // consume isPlaying = true

        mockDisplayLink.sendTick()
        let state = await iterator.next()

        #expect(state?.progressWithinBar == 0.5)
    }
}

// MARK: - Mocks

final class MockMetronomeEngine: MetronomeEngineType, @unchecked Sendable {
    // Safety: only mutated from the Metronome actor's isolation in tests.
    var playCallCount = 0
    var stopCallCount = 0
    var lastPlayedBPM: Double?
    var stubbedBarLength: Double = 100
    var stubbedSampleTime: Double = 0

    func play(bpm: Double) -> BarLength {
        playCallCount += 1
        lastPlayedBPM = bpm
        return stubbedBarLength
    }

    func stop() {
        stopCallCount += 1
    }

    var sampleTime: Double {
        stubbedSampleTime
    }
}

final class MockDisplayLinkTicker: DisplayLinkTickerType, @unchecked Sendable {
    // Safety: continuation protected by being set once before ticks are consumed.
    var pauseCallCount = 0
    var resumeCallCount = 0

    private var continuation: AsyncStream<Void>.Continuation?
    private let _ticks: AsyncStream<Void>

    init() {
        let (stream, continuation) = AsyncStream<Void>.makeStream()
        _ticks = stream
        self.continuation = continuation
    }

    var ticks: AsyncStream<Void> { _ticks }

    func pause() {
        pauseCallCount += 1
    }

    func resume() {
        resumeCallCount += 1
    }

    func sendTick() {
        continuation?.yield()
    }
}
