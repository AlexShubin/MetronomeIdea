//
//  Metronome.swift
//  MetronomeIdeaOnAVAudioEngine
//
//  Created by Alex Shubin on 26.03.17.
//  Copyright © 2017 Alex Shubin. All rights reserved.
//

import AVFoundation

class Metronome {
    
    private var audioPlayerNode:AVAudioPlayerNode
    private var audioFileMainClick:AVAudioFile
    private var audioFileAccentedClick:AVAudioFile
    private var audioEngine:AVAudioEngine
    
    init (mainClickFile: URL, accentedClickFile: URL? = nil) {
        
        audioFileMainClick = try! AVAudioFile(forReading: mainClickFile)
        audioFileAccentedClick = try! AVAudioFile(forReading: accentedClickFile ?? mainClickFile)
        
        audioPlayerNode = AVAudioPlayerNode()
        
        audioEngine = AVAudioEngine()
        audioEngine.attach(self.audioPlayerNode)
        
        audioEngine.connect(audioPlayerNode, to: audioEngine.mainMixerNode, format: audioFileMainClick.processingFormat)
        try! audioEngine.start()
    }
    
    private func generateBuffer(bpm: Double) -> AVAudioPCMBuffer {
        
        audioFileMainClick.framePosition = 0
        audioFileAccentedClick.framePosition = 0
        
        let beatLength = AVAudioFrameCount(audioFileMainClick.processingFormat.sampleRate * 60 / bpm)
        
        let bufferMainClick = AVAudioPCMBuffer(pcmFormat: audioFileMainClick.processingFormat, frameCapacity: beatLength)
        try! audioFileMainClick.read(into: bufferMainClick)
        bufferMainClick.frameLength = beatLength
        
        let bufferAccentedClick = AVAudioPCMBuffer(pcmFormat: audioFileMainClick.processingFormat, frameCapacity: beatLength)
        try! audioFileAccentedClick.read(into: bufferAccentedClick)
        bufferAccentedClick.frameLength = beatLength
        
        let bufferBar = AVAudioPCMBuffer(pcmFormat: audioFileMainClick.processingFormat, frameCapacity: 4 * beatLength)
        bufferBar.frameLength = 4 * beatLength
        
        // don't forget if we have two or more channels then we have to multiply memory pointee at channels count
        let accentedClickArray = Array(
            UnsafeBufferPointer(start: bufferAccentedClick.floatChannelData?[0],
                                count:Int(audioFileMainClick.processingFormat.channelCount) * Int(beatLength))
        )
        let mainClickArray = Array(
            UnsafeBufferPointer(start: bufferMainClick.floatChannelData?[0],
                                count:Int(audioFileMainClick.processingFormat.channelCount) * Int(beatLength))
        )
        
        var barArray = Array<Float>()
        // one time for first beat
        barArray.append(contentsOf: accentedClickArray)
        // three times for regular clicks
        for _ in 1...3 {
            barArray.append(contentsOf: mainClickArray)
        }
        
        bufferBar.floatChannelData?.pointee.assign(from: barArray,
                                                   count: Int(audioFileMainClick.processingFormat.channelCount) * Int(bufferBar.frameLength))
        
        return bufferBar
    }
    
    func play(bpm: Double) {
        
        let buffer = generateBuffer(bpm: bpm)
        
        if audioPlayerNode.isPlaying {
            audioPlayerNode.scheduleBuffer(buffer, at: nil, options: .interruptsAtLoop, completionHandler: nil)
        } else {
            self.audioPlayerNode.play()
        }
        
        self.audioPlayerNode.scheduleBuffer(buffer, at: nil, options: .loops, completionHandler: nil)
        
    }
    
    func stop() {
        audioPlayerNode.stop()
    }
    
}
