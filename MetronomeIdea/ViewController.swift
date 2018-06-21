//
//  Metronome.swift
//  MetronomeIdea
//
//  Created by Alex Shubin on 26.03.17.
//  Copyright © 2017 Alex Shubin. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var stepper: UIStepper!
    @IBOutlet weak var tempoLabel: UILabel!
    
    var metronome: Metronome = {
        let highUrl = Bundle.main.url(forResource: "High", withExtension: "wav")!
        let lowUrl = Bundle.main.url(forResource: "Low", withExtension: "wav")!
        return Metronome(mainClickFile: lowUrl, accentedClickFile: highUrl)
    }()
    var tempo = 0 {
        didSet {
            tempoLabel.text = String(self.tempo)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tempo = 120
        // stepper setup
        stepper.stepValue = 1
        stepper.minimumValue = 40
        stepper.maximumValue = 200
        stepper.value = Double(tempo)
    }
    
    @IBAction func StartPlayback(_ sender: Any) {
        metronome.play(bpm: Double(tempo))
    }
    
    @IBAction func StopPlayback(_ sender: Any) {
        metronome.stop()
    }
    
    @IBAction func stepperValueChanged(_ sender: Any) {
        tempo = Int(stepper.value)
        metronome.play(bpm: Double(tempo))
    }
}

