//
//  ContentView.swift
//  MetronomeIdea
//
//  Created by ashubin on 07.02.23.
//

import SwiftUI

struct MetronomeView: View {
    let metronome = Metronome(
        mainClickFile: Bundle.main.url(
            forResource: "Low", withExtension: "wav"
        )!,
        accentedClickFile: Bundle.main.url(
            forResource: "High", withExtension: "wav"
        )!
    )

    @State var tempo = 120

    var body: some View {
        VStack(spacing: 12) {
            Stepper("Tempo: \(tempo)", value: $tempo, in: 10...300)
                .onChange(of: tempo, perform: { newValue in
                    if metronome.isPlaying {
                        metronome.play(bpm: Double(newValue))
                    }
                })
                .frame(maxWidth: 240)
            Button("Start") {
                metronome.play(bpm: Double(tempo))
            }
            Button("Stop") {
                metronome.stop()
            }
        }
        .padding()
    }
}

struct MetronomeView_Previews: PreviewProvider {
    static var previews: some View {
        MetronomeView()
    }
}
