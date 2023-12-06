//
//  ContentView.swift
//  MinimalistFNAF
//
//  Created by Steve on 11/9/23.
//

import SwiftUI

struct TitleScreenView: View{
    var body: some View{
        VStack(spacing: 20){
            Text("Five Nights At Freddy's")
                .font(.largeTitle)
                .fontWeight(.bold)
            Text("Minimalist Edition").font(.title)
            NavigationLink("Play", destination: AISelectView())
            NavigationLink("Instructions", destination: TipsView())
        }
        .padding()
    }
}

struct ContentView: View {
    var body: some View {
        TitleScreenView()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
