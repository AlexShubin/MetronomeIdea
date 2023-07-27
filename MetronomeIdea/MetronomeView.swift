//
//  ContentView.swift
//  MetronomeIdea
//
//  Created by ashubin on 07.02.23.
//

import SwiftUI

struct MetronomeView: View {
    @ObservedObject var viewModel: MetronomeViewModel

    var body: some View {
        VStack(spacing: 12) {
            HStack {
                ForEach(viewModel.highlightedBeats) {
                    circle(highlighted: $0.highlighted)
                }
            }
            .frame(height: 20)

            Stepper("Tempo: \(viewModel.tempo)",
                    value: .init(get: { viewModel.tempo },
                                 set: { viewModel.accept(action: .tempoChanged(tempo: $0)) }),
                    in: 10...300)
            .frame(maxWidth: 240)
            Button("Start") {
                viewModel.accept(action: .play)
            }
            Button("Stop") {
                viewModel.accept(action: .stop)
            }
        }
        .padding()
    }

    @ViewBuilder
    private func circle(highlighted: Bool) -> some View {
        let size: CGFloat = highlighted ? 15 : 10

        Circle()
            .fill(highlighted ? .red : .blue)
            .frame(width: size, height: size)
            .animation(.linear(duration: 0.1), value: viewModel.highlightedBeats)
    }
}

struct MetronomeView_Previews: PreviewProvider {
    static var previews: some View {
        MetronomeView(
            viewModel: MetronomeViewModel(metronome: Metronome.sharedInstance)
        )
    }
}
