//
//  MetronomeView.swift
//  MetronomeApp
//
//  Created by Alex Shubin on 07.02.23.
//  Copyright © 2023 Alex Shubin. All rights reserved.
//

import SwiftUI

struct MetronomeView: View {
    @State var viewModel: MetronomeViewModelType
    @Environment(\.dependencies) private var dependencies

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
            Button("Settings") {
                viewModel.accept(action: .settingsTapped)
            }
        }
        .padding()
        .sheet(item: $viewModel.destination) { destination in
            switch destination {
            case .settings:
                SettingsView(viewModel: dependencies.makeSettingsViewModel())
            }
        }
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

// MARK: - Preview

@MainActor @Observable
private class PreviewMetronomeViewModel: MetronomeViewModelType {
    var tempo = 120
    var highlightedBeats: [Beat] = [
        .init(id: 0, highlighted: true),
        .init(id: 1, highlighted: true),
        .init(id: 2, highlighted: false),
        .init(id: 3, highlighted: false),
    ]
    var destination: MetronomeDestination?

    func accept(action: MetronomeViewModelAction) {}
}

#Preview {
    MetronomeView(viewModel: PreviewMetronomeViewModel())
}
