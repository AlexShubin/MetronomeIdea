//
//  Metronome.swift
//  MetronomeIdeaOnAVAudioEngine
//
//  Created by Alex Shubin on 26.03.17.
//  Copyright © 2017 Alex Shubin. All rights reserved.
//

import AVFoundation

class Metronome {
    
    var audioPlayerNode:AVAudioPlayerNode
    var audioFile:AVAudioFile
    var audioEngine:AVAudioEngine
    
    init (fileURL: URL) {
        
        audioFile = try! AVAudioFile(forReading: fileURL)
        
        audioPlayerNode = AVAudioPlayerNode()
        
        audioEngine = AVAudioEngine()
        audioEngine.attach(self.audioPlayerNode)
        
        audioEngine.connect(audioPlayerNode, to: audioEngine.mainMixerNode, format: audioFile.processingFormat)
        try! audioEngine.start()
        
    }
    
    func generateBuffer(bpm: Int) -> AVAudioPCMBuffer {
        audioFile.framePosition = 0
        let periodLength = AVAudioFrameCount(audioFile.processingFormat.sampleRate * 60 / Double(bpm))
        let buffer = AVAudioPCMBuffer(pcmFormat: audioFile.processingFormat, frameCapacity: periodLength)
        try! audioFile.read(into: buffer)
        buffer.frameLength = periodLength
        return buffer
    }
    
    func play(bpm: Int) {
        
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
