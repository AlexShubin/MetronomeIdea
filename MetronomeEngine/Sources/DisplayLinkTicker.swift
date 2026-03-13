//
//  DisplayLinkTicker.swift
//  MetronomeEngine
//
//  Created by Alex Shubin on 09.03.26.
//  Copyright © 2026 Alex Shubin. All rights reserved.
//

import QuartzCore.CADisplayLink
import Synchronization

protocol DisplayLinkTickerType {
    var ticks: AsyncStream<Void> { get }
    func pause()
    func resume()
}

class DisplayLinkTicker: DisplayLinkTickerType {
    private var displayLink: CADisplayLink!
    // Mutex protects continuation which is written from the actor (via ticks)
    // and read from the main thread (via CADisplayLink callback).
    private let continuation = Mutex<AsyncStream<Void>.Continuation?>(nil)

    var ticks: AsyncStream<Void> {
        let (stream, continuation) = AsyncStream.makeStream(of: Void.self)
        self.continuation.withLock { $0 = continuation }
        return stream
    }

    init() {
        displayLink = CADisplayLink(target: self, selector: #selector(tick))
        displayLink.add(to: .main, forMode: .default)
        displayLink.isPaused = true
    }

    func pause() {
        displayLink.isPaused = true
    }

    func resume() {
        displayLink.isPaused = false
    }

    @objc private func tick() {
        _ = continuation.withLock { $0?.yield() }
    }
}
