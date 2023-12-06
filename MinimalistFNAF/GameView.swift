//
//  GameView.swift
//  MinimalistFNAF
//
//  Created by Steve on 11/9/23.
//

import SwiftUI

struct GameView: View {
    @ObservedObject var gameState: GameState
    @State private var showGameOverScreen = false
    @State private var showVictoryScreen = false
    let freddyAI: Int
    let bonnieAI: Int
    let chicaAI: Int
    let foxyAI: Int

    
    init(freddyAI: Int, bonnieAI: Int, chicaAI: Int, foxyAI: Int) {
        //print("Game View created!")
        self.freddyAI = freddyAI
        self.bonnieAI = bonnieAI
        self.chicaAI = chicaAI
        self.foxyAI = foxyAI
        self.gameState = GameState()
    }
    
    var body: some View {
        VStack {
            HStack {
                Text("Time left: \(gameState.remainingTime)")
                Spacer()
                Text("Power: \(gameState.batteryLevel, specifier: "%.2f")%")
                Spacer()
                Text("Usage: \(gameState.totalDrainRate, specifier: "%.2f")%")
            }.padding()
            
            Spacer()
            
            Text(gameState.gameText)
                            .padding()
                            .frame(maxWidth: .infinity, maxHeight: 75)
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(8)
            Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(gameState.dangerLevel == 2 ? .red : gameState.dangerLevel == 1 ? .black : .clear)
            Spacer()
            
            if gameState.isCameraOn {
                cameraView
            } else if gameState.isPowerOutage || !gameState.isGameActive {
                powerOutageView
            }
            else {
                securityRoomView
            }
            
            Spacer()
            
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    
        .onAppear {
                gameState.startGameTimer(freddyai: freddyAI, bonnieai: bonnieAI, chicaai: chicaAI, foxyai: foxyAI)
        }
        .onDisappear{
                gameState.resetGameState()
        }
        .sheet(isPresented: $showGameOverScreen) {
            GameOverView(animatronicName: gameState.lastAttacker)
        }
        .sheet(isPresented: $showVictoryScreen) {
            GameWonView()
        }
        .onChange(of: gameState.isGameActive) { isGameActive in
            if !isGameActive && !gameState.isVictory {
                showGameOverScreen = true
            } else if !isGameActive && gameState.isVictory {
                showVictoryScreen = true
            }
        }
    }
    
    
    var powerOutageView: some View {
        Text("")
    }
    
    var securityRoomView: some View {
        VStack(spacing: 20) {
            Spacer()
            // Row with labels for left and right doors
            HStack(spacing: 20){
                HStack {
                    Text("Left Door")
                    Image(systemName: gameState.isLeftDoorClosed ? "lock.fill" : "lock.open")
                }
                .frame(width: 125, height: 50)

                Spacer()

                HStack {
                    Text("Right Door")
                    Image(systemName: gameState.isRightDoorClosed ? "lock.fill" : "lock.open")
                }
                .frame(width: 125, height: 50)
            }

            
            // Row with buttons for left and right doors
            HStack(spacing: 20) {
                Button(gameState.isLeftDoorClosed ? "Open" : "Close") {
                    gameState.toggleLeftDoor()
                }.frame(width: 125, height: 50)
                .background(gameState.isLeftDoorClosed ? Color.gray.opacity(0.5) : Color.clear)
                    .disabled(gameState.isLeftDoorDisabled)

                Spacer()

                Button(gameState.isRightDoorClosed ? "Open" : "Close") {
                    gameState.toggleRightDoor()
                }.frame(width: 125, height: 50)
                .background(gameState.isRightDoorClosed ? Color.gray.opacity(0.5) : Color.clear)
                    .disabled(gameState.isRightDoorDisabled)
            }

            // Row with buttons to check left and right doors
            HStack(spacing: 20) {
                Button(action: {
                    gameState.checkLeftDoor()
                }) {
                    HStack {
                        Text("Check")
                        Image(systemName: "lightbulb")
                    }
                }
                .frame(width: 125, height: 50)
                .disabled(gameState.isLeftDoorDisabled)


                Spacer()

                Button(action: {
                    gameState.checkRightDoor()
                }) {
                    HStack {
                        Text("Check")
                        Image(systemName: "lightbulb")
                    }
                }
                .frame(width: 125, height: 50)
                .disabled(gameState.isRightDoorDisabled)

            }

            Spacer()
            Button(action: {gameState.accessCameras()}) {
                HStack {
                    Text("Access Cameras")
                    Image(systemName: "video")
                }
            }
        }
        .padding()
    }
    
    var cameraView: some View {
        VStack(spacing: 20) {
            Spacer()
            // Row 1
            HStack(spacing: 20) {
                Spacer()
                Spacer()
                Button("CAM 1A") {
                    gameState.checkCamera(locationstring: "Show Stage")
                }.frame(width: 50, height: 50)
                .background(Color.gray.opacity(0.5))
                Spacer()
                Spacer()
            }
            
            // Row 2
            HStack(spacing: 20) {
                Button("CAM 5") {
                    gameState.checkCamera(locationstring: "Backstage")
                }.frame(width: 50, height: 50)
                .background(Color.gray.opacity(0.5))
                Color.gray.opacity(0.5).frame(width: 50, height: 50)
                Button("CAM 1B") {
                    gameState.checkCamera(locationstring: "Dining Area")
                }.frame(width: 50, height: 50)
                .background(Color.gray.opacity(0.5))
                Color.gray.opacity(0.5).frame(width: 50, height: 50)
                Button("CAM 7") {
                    gameState.checkCamera(locationstring: "Restrooms")
                }.frame(width: 50, height: 50)
                .background(Color.gray.opacity(0.5))
            }
            
            // Row 3
            HStack(spacing: 20) {
                Spacer()
                Button("CAM 1C") {
                    gameState.checkCamera(locationstring: "Pirate's Cove")
                }.frame(width: 50, height: 50)
                .background(Color.gray.opacity(0.5))
                Color.gray.opacity(0.5).frame(width: 50, height: 50)
                Color.gray.opacity(0.5).frame(width: 50, height: 50)
                Spacer()
            }
            
            // Row 4
            HStack(spacing: 20) {
                Color.clear.frame(width: 50, height: 50)
                Color.gray.opacity(0.5).frame(width: 50, height: 50)
                Color.gray.opacity(0.5).frame(width: 50, height: 50)
                Color.gray.opacity(0.5).frame(width: 50, height: 50)
                Button("CAM 6 ") {
                    gameState.checkCamera(locationstring: "Kitchen")
                }.frame(width: 50, height: 50)
                .background(Color.gray.opacity(0.5))
            }
            
            // Row 5
            HStack(spacing: 20) {
                Button("CAM 3 ") {
                    gameState.checkCamera(locationstring: "Supply Closet")
                }.frame(width: 50, height: 50)
                .background(Color.gray.opacity(0.5))
                Button("CAM 2A") {
                    gameState.checkCamera(locationstring: "West Hall")
                }.frame(width: 50, height: 50)
                .background(Color.gray.opacity(0.5))
                Color.clear.frame(width: 50, height: 50)
                Button("CAM 4A") {
                    gameState.checkCamera(locationstring: "East Hall")
                }.frame(width: 50, height: 50)
                .background(Color.gray.opacity(0.5))
                Color.clear.frame(width: 50, height: 50)
            }
            
            // Row 6
            HStack(spacing: 20) {
                Spacer()
                Button("CAM 2B") {
                    gameState.checkCamera(locationstring: "West Hall Corner")
                }.frame(width: 50, height: 50)
                .background(Color.gray.opacity(0.5))
                
                Text("You").frame(width: 50, height: 50).background(Color.green.opacity(0.5))
                
                Button("CAM 4B") {
                    gameState.checkCamera(locationstring: "East Hall Corner")
                }.frame(width: 50, height: 50)
                .background(Color.gray.opacity(0.5))
                Spacer()
            }
            
            Spacer()
            // Return to security room button
            Button(action: {gameState.returnToSecurityRoom()}) {
                HStack {
                    Text("Exit Cameras")
                    Image(systemName: "eye")
                }
            }
        }
        .padding()
    }
        
}

struct GameWonView: View {

    var body: some View {
        VStack {
            Text("🎉").font(.system(size: 100))
            Text("You survived the night! You win.")
                .font(.title)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.green.opacity(0.7))
    }
}

struct GameOverView: View {
    let animatronicName: String

    var body: some View {
        VStack {
            Text(iconForAnimatronic(animatronicName))
                            .font(.system(size: 100))
            Text("\(animatronicName) attacked you! You lose.")
                .font(.title)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.red.opacity(0.7))
    }
    
    private func iconForAnimatronic(_ name: String) -> String {
        switch name {
            case "Freddy":
                return "🐻"
            case "Bonnie":
                return "🐰"
            case "Chica":
                return "🐤"
            case "Foxy":
                return "🦊"
            default:
                return "❓"
        }
    }
}

struct GameView_Previews: PreviewProvider {
    static var previews: some View {
        GameView(freddyAI: 0, bonnieAI: 0, chicaAI: 0, foxyAI: 0)
    }
}
