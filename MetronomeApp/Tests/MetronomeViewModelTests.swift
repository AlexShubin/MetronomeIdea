//
//  MetronomeViewModelTests.swift
//  MetronomeAppTests
//
//  Created by Alex Shubin on 25.03.26.
//  Copyright © 2026 Alex Shubin. All rights reserved.
//

import Testing
import MetronomeEngine
import MetronomeTestSupport
@testable import MetronomeApp

@Suite @MainActor
struct MetronomeViewModelTests {
    let mockMetronome: MockMetronome
    let sut: MetronomeViewModel

    init() {
        mockMetronome = .init()
        sut = MetronomeViewModel(metronome: mockMetronome)
    }

    @Test func initialState() {
        #expect(sut.state == .initial)
    }

    @Test func stateUpdates_onMetronomeStateChange() async throws {
        await mockMetronome.sendState(
            MetronomeState(tempo: 140, isPlaying: true, progressWithinBar: 0.3)
        )
        try await Task.sleep(for: .milliseconds(10))

        #expect(sut.state.tempo == 140)
        #expect(sut.state.playButtonState == .stop)
        #expect(sut.state.beats[0].highlighted == false)
        #expect(sut.state.beats[1].highlighted == true)
        #expect(sut.state.beats[2].highlighted == false)
        #expect(sut.state.beats[3].highlighted == false)
    }

    @Test func playStopTapped_whenStopped_callsPlay() async throws {
        sut.accept(action: .playStopTapped)
        try await Task.sleep(for: .milliseconds(10))

        let calls = await mockMetronome.calls
        #expect(calls == [.play])
    }

    @Test func playStopTapped_whenPlaying_callsStop() async throws {
        await mockMetronome.sendState(
            MetronomeState(tempo: 120, isPlaying: true, progressWithinBar: 0)
        )
        try await Task.sleep(for: .milliseconds(10))

        sut.accept(action: .playStopTapped)
        try await Task.sleep(for: .milliseconds(10))

        let calls = await mockMetronome.calls
        #expect(calls == [.stop])
    }

    @Test func tempoChanged_callsChangeTempo() async throws {
        sut.accept(action: .tempoChanged(tempo: 180))
        try await Task.sleep(for: .milliseconds(10))

        let calls = await mockMetronome.calls
        #expect(calls == [.changeTempo(bpm: 180)])
    }

    @Test func settingsTapped_setsDestination() {
        sut.accept(action: .settingsTapped)

        #expect(sut.destination == .settings)
    }

    @Test func beatHighlighting_firstQuarter() async throws {
        await mockMetronome.sendState(
            MetronomeState(tempo: 120, isPlaying: true, progressWithinBar: 0.1)
        )
        try await Task.sleep(for: .milliseconds(10))

        #expect(sut.state.beats[0].highlighted == true)
        #expect(sut.state.beats[1].highlighted == false)
    }

    @Test func beatHighlighting_thirdQuarter() async throws {
        await mockMetronome.sendState(
            MetronomeState(tempo: 120, isPlaying: true, progressWithinBar: 0.6)
        )
        try await Task.sleep(for: .milliseconds(10))

        #expect(sut.state.beats[2].highlighted == true)
    }

    @Test func beats_whenNotPlaying_allUnhighlighted() async throws {
        await mockMetronome.sendState(
            MetronomeState(tempo: 120, isPlaying: false, progressWithinBar: 0.5)
        )
        try await Task.sleep(for: .milliseconds(10))

        #expect(sut.state.beats == MetronomeViewState.initial.beats)
    }
}
