
import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var stepper: UIStepper!
    @IBOutlet weak var tempoLabel: UILabel!
    
    var metronome: Metronome = {
        let fileUrl = Bundle.main.url(forResource: "Click", withExtension: "wav")!
        return Metronome(fileURL: fileUrl)
    }()
    var tempo: Double = 0 { didSet {
            tempoLabel.text = String(self.tempo)
        }
    }
    
    override func viewDidLoad() {
        tempo = 120
        stepperSetup()
    }
    
    func stepperSetup() {
        stepper.stepValue = 0.01
        stepper.minimumValue = 40
        stepper.maximumValue = 200
        stepper.value = tempo
    }
    
    @IBAction func StartPlayback(_ sender: Any) {
        metronome.play(bpm: tempo)
    }
    
    @IBAction func StopPlayback(_ sender: Any) {
        metronome.stop()
    }
    
    @IBAction func stepperValueChanged(_ sender: Any) {
        tempo = stepper.value
        metronome.play(bpm: tempo)
    }

}

