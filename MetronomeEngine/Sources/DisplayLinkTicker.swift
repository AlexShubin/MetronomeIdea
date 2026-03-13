//
//  DisplayLinkTicker.swift
//  MetronomeApp
//
//  Created by Alex Shubin on 09.03.26.
//  Copyright © 2026 Alex Shubin. All rights reserved.
//

import QuartzCore.CADisplayLink

protocol DisplayLinkTickerType {
    var ticks: AsyncStream<Void> { get }
    func pause()
    func resume()
}

class DisplayLinkTicker: DisplayLinkTickerType {
    private var displayLink: CADisplayLink!
    private var continuation: AsyncStream<Void>.Continuation?

    var ticks: AsyncStream<Void> {
        let (stream, continuation) = AsyncStream.makeStream(of: Void.self)
        self.continuation = continuation
        return stream
    }

    init() {
        displayLink = CADisplayLink(target: self, selector: #selector(tick))
        displayLink.add(to: .current, forMode: .default)
        displayLink.isPaused = true
    }

    func pause() {
        displayLink.isPaused = true
    }

    func resume() {
        displayLink.isPaused = false
    }

    @objc private func tick() {
        continuation?.yield()
    }
}
