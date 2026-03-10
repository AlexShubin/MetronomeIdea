//
//  DisplayLinkStream.swift
//  MetronomeIdea
//
//  Created by Alex Shubin on 09.03.26.
//  Copyright © 2026 Alex Shubin. All rights reserved.
//

import QuartzCore.CADisplayLink

protocol DisplayLinkStreamType {
    var ticks: AsyncStream<Void> { get }
    func pause()
    func resume()
}

class DisplayLinkStream: DisplayLinkStreamType {
    private var displayLink: CADisplayLink!
    private var continuation: AsyncStream<Void>.Continuation?

    var ticks: AsyncStream<Void> {
        AsyncStream { continuation in
            self.continuation = continuation
            continuation.onTermination = { [weak self] _ in
                self?.continuation = nil
            }
        }
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
