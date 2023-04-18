//
//  ContentView.swift
//  MetronomeIdea
//
//  Created by ashubin on 07.02.23.
//

import SwiftUI

struct MetronomeView: View {
    @ObservedObject var metronome: Metronome

    init() {
        metronome = Metronome(
            mainClickFile: Bundle.main.url(
                forResource: "Low", withExtension: "wav"
            )!,
            accentedClickFile: Bundle.main.url(
                forResource: "High", withExtension: "wav"
            )!
        )
    }

    @State var tempo = 120

    var body: some View {
        VStack(spacing: 12) {
            HStack {
                circleBasedOn(division: 0)
                circleBasedOn(division: 0.25)
                circleBasedOn(division: 0.5)
                circleBasedOn(division: 0.75)
            }
            .frame(height: 20)

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

    @ViewBuilder
    private func circleBasedOn(division: CGFloat) -> some View {
        let size: CGFloat = metronome.currentProgressWithinBar > division ? 15 : 10

        Circle()
            .fill(metronome.currentProgressWithinBar > division ? .red : .blue)
            .frame(width: size, height: size)
            .animation(.linear(duration: 0.1), value: metronome.currentProgressWithinBar)
    }
}

struct MetronomeView_Previews: PreviewProvider {
    static var previews: some View {
        MetronomeView()
    }
}
