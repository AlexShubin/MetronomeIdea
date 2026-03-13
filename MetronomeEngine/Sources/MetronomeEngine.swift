//
//  Metronome.swift
//  MetronomeEngine
//
//  Created by Alex Shubin on 26.03.17.
//  Copyright © 2017 Alex Shubin. All rights reserved.
//

import AVFoundation

protocol MetronomeEngineType {
    /// Starts the metronome.
    /// - Parameter bpm: Tempo. Beats per minute.
    /// - Returns: Returns the bar length in frames, so later on we can understand the position of the player within the bar.
    func play(bpm: Double) -> BarLength

    func stop()

    var isPlaying: Bool { get }
    
    /// Accumulative time of the playhead.
    /// Note that if it played two bars in total, it will return the accumulative time of two bars.
    var sampleTime: Double { get }
}

typealias BarLength = Double

class MetronomeEngine: MetronomeEngineType {
    private let audioPlayerNode: AVAudioPlayerNode
    private let audioFileMainClick: AVAudioFile
    private let audioFileAccentedClick: AVAudioFile
    private let audioEngine: AVAudioEngine

    init() {
        let mainClickFile = Bundle.module.url(forResource: "Low", withExtension: "wav")!
        let accentedClickFile = Bundle.module.url(forResource: "High", withExtension: "wav")!

        audioFileMainClick = try! AVAudioFile(forReading: mainClickFile)
        audioFileAccentedClick = try! AVAudioFile(forReading: accentedClickFile)
        
        audioPlayerNode = AVAudioPlayerNode()
        
        audioEngine = AVAudioEngine()
        audioEngine.attach(self.audioPlayerNode)
        
        audioEngine.connect(audioPlayerNode, to: audioEngine.mainMixerNode, format: audioFileMainClick.processingFormat)
        try! audioEngine.start()
    }

    func stop() {
        audioPlayerNode.stop()
    }

    var isPlaying: Bool {
        audioPlayerNode.isPlaying
    }

    func play(bpm: Double) -> BarLength {
        let buffer = generateBuffer(bpm: bpm)
        
        if audioPlayerNode.isPlaying {
            audioPlayerNode.stop()
        }
        
        audioPlayerNode.play()
        
        audioPlayerNode.scheduleBuffer(
            buffer,
            at: nil,
            options: [.interruptsAtLoop, .loops]
        )

        return Double(buffer.frameLength)
    }

    var sampleTime: Double {
        guard let nodeTime = audioPlayerNode.lastRenderTime,
              let playerTime = audioPlayerNode.playerTime(forNodeTime: nodeTime) else {
            return 0
        }

        return Double(playerTime.sampleTime)
    }

    private func generateBuffer(bpm: Double) -> AVAudioPCMBuffer {
        audioFileMainClick.framePosition = 0
        audioFileAccentedClick.framePosition = 0
        
        let format = audioFileMainClick.processingFormat
        let beatLength = AVAudioFrameCount(format.sampleRate * 60 / bpm)
        let channelCount = Int(format.channelCount)

        let accentedClickSamples = readSamples(from: audioFileAccentedClick, format: format, beatLength: beatLength)
        let mainClickSamples = readSamples(from: audioFileMainClick, format: format, beatLength: beatLength)

        var barSamples = accentedClickSamples
        for _ in 1...3 {
            barSamples.append(contentsOf: mainClickSamples)
        }

        let bufferBar = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: 4 * beatLength)!
        bufferBar.frameLength = 4 * beatLength
        bufferBar.floatChannelData!.pointee.update(from: barSamples,
                                                   count: channelCount * Int(bufferBar.frameLength))
        return bufferBar
    }

    private func readSamples(
        from file: AVAudioFile,
        format: AVAudioFormat,
        beatLength: AVAudioFrameCount
    ) -> [Float] {
        let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: beatLength)!
        try! file.read(into: buffer)
        buffer.frameLength = beatLength
        let sampleCount = Int(format.channelCount) * Int(beatLength)
        return Array(UnsafeBufferPointer(start: buffer.floatChannelData![0], count: sampleCount))
    }
}
