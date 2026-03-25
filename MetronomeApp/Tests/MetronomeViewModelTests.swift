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

    @Test func stateUpdates_onMetronomeStateChange() {
        sut.applyState(
            MetronomeState(tempo: 140, isPlaying: true, progressWithinBar: 0.3)
        )

        #expect(sut.state.tempo == 140)
        #expect(sut.state.playButtonState == .stop)
        #expect(sut.state.beats[0].highlighted == false)
        #expect(sut.state.beats[1].highlighted == true)
        #expect(sut.state.beats[2].highlighted == false)
        #expect(sut.state.beats[3].highlighted == false)
    }

    @Test func playStopTapped_whenStopped_callsPlay() async {
        await sut.accept(action: .playStopTapped)

        let calls = await mockMetronome.calls
        #expect(calls == [.play])
    }

    @Test func playStopTapped_whenPlaying_callsStop() async {
        sut.applyState(
            MetronomeState(tempo: 120, isPlaying: true, progressWithinBar: 0)
        )

        await sut.accept(action: .playStopTapped)

        let calls = await mockMetronome.calls
        #expect(calls == [.stop])
    }

    @Test func tempoChanged_callsChangeTempo() async {
        await sut.accept(action: .tempoChanged(tempo: 180))

        let calls = await mockMetronome.calls
        #expect(calls == [.changeTempo(bpm: 180)])
    }

    @Test func settingsTapped_setsDestination() async {
        await sut.accept(action: .settingsTapped)

        #expect(sut.destination == .settings)
    }

    @Test func beatHighlighting_firstQuarter() {
        sut.applyState(
            MetronomeState(tempo: 120, isPlaying: true, progressWithinBar: 0.1)
        )

        #expect(sut.state.beats[0].highlighted == true)
        #expect(sut.state.beats[1].highlighted == false)
    }

    @Test func beatHighlighting_thirdQuarter() {
        sut.applyState(
            MetronomeState(tempo: 120, isPlaying: true, progressWithinBar: 0.6)
        )

        #expect(sut.state.beats[2].highlighted == true)
    }

    @Test func beats_whenNotPlaying_allUnhighlighted() {
        sut.applyState(
            MetronomeState(tempo: 120, isPlaying: false, progressWithinBar: 0.5)
        )

        #expect(sut.state.beats == MetronomeViewState.initial.beats)
    }
}
