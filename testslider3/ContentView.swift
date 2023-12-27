//
//  ContentView.swift
//  testslider3
//
//  Created by Bjørn Inge Berg on 16/10/2023.
//

import SwiftUI
import SlideButton

@main
struct SliderApp : App {
    init () {
        UserDefaults.standard.set(["ar"], forKey: "AppleLanguages")
    }
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.locale, Locale(identifier: "ar"))
                .environment(\.layoutDirection, .rightToLeft)
        }
    }
}

struct ContentView: View {
    static var mockInserter = MockCannulaInserter()
    static var model = InsertCannulaViewModel(cannulaInserter: mockInserter)
    
   
    var body: some View {
        InsertCannulaView(viewModel: ContentView.model)
    }
}

#Preview {
    ContentView()
}



