//
//  AISelectView.swift
//  MinimalistFNAF
//
//  Created by Steve on 11/9/23.
//

import SwiftUI

struct AISelectView: View {
    @State private var freddyAI: Int = 0
    @State private var bonnieAI: Int = 0
    @State private var chicaAI: Int = 0
    @State private var foxyAI: Int = 0
    @State private var showGameView = false

    
    let aiRange = 0...20

    var body: some View {
        VStack {
            Text("Set AI Difficulty (0-20)")
                .font(.title)
            Text("0 = Inactive, 20 = Maximum Aggression")
                .font(.subheadline)

            Text("Easy: (0, 2, 1, 1)")
            Text("Medium: (2, 4, 5, 3)")
            Text("Hard: (3, 8, 9, 7)")

            Text("Warning: Some AI levels increase over time!")
                .font(.caption)
                .foregroundColor(.red)
            
            Form {
                Section(header: Text("Animatronics")) {
                    Picker("Freddy 🐻", selection: $freddyAI) {
                        ForEach(aiRange, id: \.self) { number in
                                            Text("\(number)").tag(number)
                        }
                    }
                                    
                    Picker("Bonnie 🐰", selection: $bonnieAI) {
                        ForEach(aiRange, id: \.self) { number in
                                            Text("\(number)").tag(number)
                        }
                    }
                                    
                    Picker("Chica 🐤", selection: $chicaAI) {
                        ForEach(aiRange, id: \.self) { number in
                                            Text("\(number)").tag(number)
                        }
                    }
                                    
                    Picker("Foxy 🦊", selection: $foxyAI) {
                        ForEach(aiRange, id: \.self) { number in
                                            Text("\(number)").tag(number)
                        }
                    }
                }
            }
            .frame(height: 250)

            Button("Start") {
                showGameView = true
            }
            .sheet(isPresented: $showGameView){
                GameView(freddyAI: freddyAI, bonnieAI: bonnieAI, chicaAI: chicaAI, foxyAI: foxyAI)
            }
            
                
        }
    }
}

struct AISelectView_Previews: PreviewProvider {
    static var previews: some View {
        AISelectView()
    }
}
