//
//  DisplayLinkTicker.swift
//  MetronomeIdea
//
//  Created by Alex Shubin on 09.03.26.
//  Copyright © 2026 Alex Shubin. All rights reserved.
//

import Combine
import QuartzCore.CADisplayLink

protocol DisplayLinkTickerType {
    var ticks: AnyPublisher<Void, Never> { get }
    func pause()
    func resume()
}

class DisplayLinkTicker: DisplayLinkTickerType {
    private var displayLink: CADisplayLink!
    private let subject = PassthroughSubject<Void, Never>()

    var ticks: AnyPublisher<Void, Never> {
        subject.eraseToAnyPublisher()
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
        subject.send()
    }
}
