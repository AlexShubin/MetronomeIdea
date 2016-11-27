
import UIKit
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


class ViewController: UIViewController {

    @IBOutlet weak var stepper: UIStepper!
    @IBOutlet weak var tempoLabel: UILabel!
    
    var metronome:Metronome
    var tempo:Int { didSet {
        
            tempoLabel.text = String(self.tempo)
        
        }
    }
        
    required init?(coder aDecoder: NSCoder) {
        
        let fileUrl = Bundle.main.url(forResource: "Click", withExtension: "wav")!
        
        metronome = Metronome(fileURL: fileUrl)
        
        tempo = 120
        
        super.init(coder: aDecoder)
        
    }
    
    override func viewDidLoad() {
        
        stepper.value = Double(tempo)
        stepper.stepValue = 1
        stepper.minimumValue = 40
        stepper.maximumValue = 200
        
    }
    
    @IBAction func StartPlayback(_ sender: Any) {
        
        metronome.play(bpm: tempo)
        
    }
    
    @IBAction func StopPlayback(_ sender: Any) {
        
        metronome.stop()
        
    }
    
    @IBAction func stepperValueChanged(_ sender: Any) {
        
        tempo = Int(stepper.value)
        metronome.play(bpm: tempo)
    }

}

