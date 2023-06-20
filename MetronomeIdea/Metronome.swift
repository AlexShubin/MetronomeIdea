//
//  Metronome.swift
//  MetronomeIdea
//
//  Created by Alex Shubin on 26.03.17.
//  Copyright © 2017 Alex Shubin. All rights reserved.
//

import AVFoundation

class Metronome: ObservableObject {
    /// Current progress within the bar. Changes from 0 to 1.
    @Published var currentProgressWithinBar: Double = 0

    private let audioPlayerNode: AVAudioPlayerNode
    private let audioFileMainClick: AVAudioFile
    private let audioFileAccentedClick: AVAudioFile
    private let audioEngine: AVAudioEngine

    private lazy var displayLink: CADisplayLink = {
        let displayLink = CADisplayLink(target: self, selector: #selector(updateCurrentTime))
        displayLink.add(to: .current, forMode: .default)
        return displayLink
    }()

    private var currentBuffer: AVAudioPCMBuffer?

    init (mainClickFile: URL, accentedClickFile: URL? = nil) {
        audioFileMainClick = try! AVAudioFile(forReading: mainClickFile)
        audioFileAccentedClick = try! AVAudioFile(forReading: accentedClickFile ?? mainClickFile)
        
        audioPlayerNode = AVAudioPlayerNode()
        
        audioEngine = AVAudioEngine()
        audioEngine.attach(self.audioPlayerNode)
        
        audioEngine.connect(audioPlayerNode, to: audioEngine.mainMixerNode, format: audioFileMainClick.processingFormat)
        try! audioEngine.start()
    }

    func stop() {
        audioPlayerNode.stop()
        displayLink.isPaused = true
        currentProgressWithinBar = 0
    }

    var isPlaying: Bool {
        audioPlayerNode.isPlaying
    }

    func play(bpm: Double) {
        let buffer = generateBuffer(bpm: bpm)

        currentBuffer = buffer

        if audioPlayerNode.isPlaying {
            audioPlayerNode.stop()
        }

        displayLink.isPaused = false
        audioPlayerNode.play()

        audioPlayerNode.scheduleBuffer(
            buffer,
            at: nil,
            options: [.interruptsAtLoop, .loops]
        )
    }

    @objc private func updateCurrentTime() {
        guard let nodeTime = audioPlayerNode.lastRenderTime,
              let playerTime = audioPlayerNode.playerTime(forNodeTime: nodeTime),
              let buffer = currentBuffer else {
            currentProgressWithinBar = 0
            return
        }

        currentProgressWithinBar = Double(playerTime.sampleTime)
            .truncatingRemainder(dividingBy: Double(buffer.frameLength))
        / Double(buffer.frameLength)
    }
    
    private func generateBuffer(bpm: Double) -> AVAudioPCMBuffer {
        audioFileMainClick.framePosition = 0
        audioFileAccentedClick.framePosition = 0
        
        let beatLength = AVAudioFrameCount(audioFileMainClick.processingFormat.sampleRate * 60 / bpm)
        let bufferMainClick = AVAudioPCMBuffer(pcmFormat: audioFileMainClick.processingFormat,
                                               frameCapacity: beatLength)!
        try! audioFileMainClick.read(into: bufferMainClick)
        bufferMainClick.frameLength = beatLength
        
        let bufferAccentedClick = AVAudioPCMBuffer(pcmFormat: audioFileMainClick.processingFormat,
                                                   frameCapacity: beatLength)!
        try! audioFileAccentedClick.read(into: bufferAccentedClick)
        bufferAccentedClick.frameLength = beatLength
        
        let bufferBar = AVAudioPCMBuffer(pcmFormat: audioFileMainClick.processingFormat,
                                         frameCapacity: 4 * beatLength)!
        bufferBar.frameLength = 4 * beatLength
        
        // don't forget if we have two or more channels then we have to multiply memory pointee at channels count
        let channelCount = Int(audioFileMainClick.processingFormat.channelCount)
        let accentedClickArray = Array(
            UnsafeBufferPointer(start: bufferAccentedClick.floatChannelData![0],
                                count: channelCount * Int(beatLength))
        )
        let mainClickArray = Array(
            UnsafeBufferPointer(start: bufferMainClick.floatChannelData![0],
                                count: channelCount * Int(beatLength))
        )
        
        var barArray = [Float]()
        // one time for first beat
        barArray.append(contentsOf: accentedClickArray)
        // three times for regular clicks
        for _ in 1...3 {
            barArray.append(contentsOf: mainClickArray)
        }
        bufferBar.floatChannelData!.pointee.update(from: barArray,
                                                   count: channelCount * Int(bufferBar.frameLength))
        return bufferBar
    }
}
