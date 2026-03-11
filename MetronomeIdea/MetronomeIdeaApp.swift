//
//  MetronomeIdeaApp.swift
//  MetronomeIdea
//
//  Created by Alex Shubin on 07.02.23.
//  Copyright © 2023 Alex Shubin. All rights reserved.
//

import SwiftUI

@main
struct MetronomeIdeaApp: App {
    @Environment(\.viewModelFactory) private var viewModelFactory

    var body: some Scene {
        WindowGroup {
            MetronomeView(viewModel: viewModelFactory.makeMetronomeViewModel())
        }
    }
}
