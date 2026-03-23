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
