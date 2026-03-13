//
//  Dependencies.swift
//  MetronomeEngine
//
//  Created by Alex Shubin on 13.03.26.
//  Copyright © 2026 Alex Shubin. All rights reserved.
//

public enum Dependencies {
    public static let metronome: MetronomeType = Metronome(
        metronomeEngine: MetronomeEngine(),
        displayLink: DisplayLinkTicker()
    )
}
