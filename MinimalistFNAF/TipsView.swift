//
//  TipsView.swift
//  MinimalistFNAF
//
//  Created by Steve on 11/9/23.
//

import SwiftUI

struct TipsView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                Text("How to Play")
                    .font(.title)
                    .fontWeight(.bold)
                ForEach(howToPlayTips, id: \.self) { tip in
                    HStack(alignment: .top) {
                        Text("•")
                            .fontWeight(.bold)
                        Text(tip)
                    }
                }

                Text("Hints")
                    .font(.title)
                    .fontWeight(.bold)
                ForEach(hints, id: \.self) { hint in
                    HStack(alignment: .top) {
                        Text("•")
                            .fontWeight(.bold)
                        Text(hint)
                    }
                }
            }
            .padding()
        }
        
    }
    
    let howToPlayTips = [
            "You are a security guard at a pizzeria, working the night shift. Four animatronic mascots will try to approach the security office to attack you.",
            "Your office has two doors to your left and right, and a camera monitor.",
            "Use the cameras 📹 to keep track of the animatronics' locations and close 🔒 the doors to defend yourself. You can also check 💡 the doors to see if an animatronic is right outside the office.",
            "The office has limited power. Using the cameras, closing the doors, and checking the doors will all consume power. If the power runs out, you become vulnerable.",
            "Survive 535 seconds to win!"
    ]

    let hints = [
        "Closing 🔒 the doors ensures your safety, but consumes a lot of power. Use them only when absolutely necessary.",
        "There are blindspots right outside the left and right doors that the cameras do not cover. If an animatronic is not spotted on the cameras, try checking 💡 the doors. But be quick!",
        "Bonnie 🐰, Chica 🐤, and Freddy 🐻 start at the Show Stage (CAM 1A). Freddy always leaves last.",
        "Foxy 🦊 starts at Pirate's Cove (CAM 1C) and gradually prepares to leave. He doesn't like being watched, so he is less likely to leave the more you use the cameras.",
        "If Foxy 🦊 leaves Pirate's Cove, he sprints straight to the office. You have only a short moment to close 🔒 the left door.",
        "Freddy 🐻 doesn't like being watched either, but knows when the cameras are on him specifically. Find him on the cameras to slow him down!",
        "Bonnie 🐰 prefers the west side of the building, while Chica 🐤 prefers the east side.",
        "If you notice your door controls are disabled, then you are already doomed."
    ]

}

struct TipsView_Previews: PreviewProvider {
    static var previews: some View {
        TipsView()
    }
}
