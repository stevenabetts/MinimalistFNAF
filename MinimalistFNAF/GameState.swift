//
//  GameState.swift
//  MinimalistFNAF
//
//  Created by Steve on 11/14/23.
//

import Foundation

class GameState: ObservableObject {
    //Game flags
    @Published var isGameActive: Bool
    @Published var isPowerOutage: Bool
    @Published var isLeftDoorClosed: Bool
    @Published var isRightDoorClosed: Bool
    @Published var isLeftDoorDisabled: Bool
    @Published var isRightDoorDisabled: Bool
    @Published var isCameraOn: Bool
    var isVictory: Bool
    
    //Game Resources & Constants
    @Published var remainingTime: Int
    @Published var batteryLevel: Float
    @Published var totalDrainRate: Float
    let normalDrainRate: Float
    let doorDrainModifier: Float
    let cameraDrainModifier: Float
    let checkDoorDrain: Float
    var lastCameraViewed: Location?
    var lastAttacker: String = ""
    @Published var dangerLevel: Int = 0
    
    //Game Timer
    var gameTimer: Timer?
    
    //Game Text
    @Published var gameText: String = "You are in the security office."
    
    //Game Locations
    var locations: [String: Location] = [:]
    
    //Animatronics
    var freddy: Freddy?
    var bonnie: Bonnie?
    var chica: Chica?
    var foxy: Foxy?
    
    init(){
        isGameActive = false
        isPowerOutage = false
        isLeftDoorClosed = false
        isRightDoorClosed = false
        isLeftDoorDisabled = false
        isRightDoorDisabled = false
        isCameraOn = false
        isVictory = false
        
        remainingTime = 535
        batteryLevel = 100.00
        totalDrainRate = 0.00
        normalDrainRate = 1/7
        doorDrainModifier = 0.09
        cameraDrainModifier = 0.08
        checkDoorDrain = 0.04
        
        locations["Show Stage"] = Location(name:"Show Stage", capacity: 3)
        locations["Dining Area"] = Location(name: "Dining Area", capacity: 3)
        locations["Backstage"] = Location(name: "Backstage", capacity: 3)
        locations["Restrooms"] = Location(name: "Restrooms", capacity: 2)
        locations["Pirate's Cove"] = Location(name: "Pirate's Cove", capacity: 1)
        locations["Supply Closet"] = Location(name: "Supply Closet", capacity: 1)
        locations["Kitchen"] = Location(name: "Kitchen", capacity: 2)
        locations["West Hall"] = Location(name: "West Hall", capacity: 2)
        locations["East Hall"] = Location(name: "East Hall", capacity: 2)
        locations["West Hall Corner"] = Location(name: "West Hall Corner", capacity: 1)
        locations["East Hall Corner"] = Location(name: "East Hall Corner", capacity: 1)
        locations["Outside West Door"] = Location(name: "Outside West Door", capacity: 1)
        locations["Outside East Door"] = Location(name: "Outside East Door", capacity: 1)
        locations["Office"] = Location(name: "Office", capacity: 1)
        
        freddy = Freddy(aggression: 0, gameState: self)
        bonnie = Bonnie(aggression: 0, gameState: self)
        chica = Chica(aggression: 0, gameState: self)
        foxy = Foxy(aggression: 0, gameState: self)
        
        print("GameState created!")
    }
    
    deinit {
        gameTimer?.invalidate()
        gameTimer = nil
        print("GameState destroyed!")
    }
    
    //Drain battery function (used only by Foxy)
    func drainBattery(by amount: Float){
        batteryLevel -= amount
    }
    
    //Disable doors functions (used by chica and bonnie)
    func disableLeftDoor(){
        isLeftDoorDisabled = true
    }
    func disableRightDoor(){
        isRightDoorDisabled = true
    }
    
    //Trigger danger levels which will reflect in the UI
    func triggerDanger(level danger: Int) {
        self.dangerLevel = danger
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.dangerLevel = 0
        }
    }
    
    //Render time function
    @objc func renderTime() {
        guard let bonnie = bonnie,
              let chica = chica,
              let foxy = foxy else {
            print("Existence error in renderTime!")
            return;
        }
        
        remainingTime -= 1
        
        if remainingTime == 357 {
            bonnie.aggression += 1
            print("Bonnie's aggression increased to \(bonnie.aggression).")
        }
        if remainingTime == 268 {
            bonnie.aggression += 1
            chica.aggression += 1
            foxy.aggression += 1
            print("Bonnie's aggression increased to \(bonnie.aggression).")
            print("Chica's aggression increased to \(chica.aggression).")
            print("Foxy's aggression increased to \(foxy.aggression).")
        }
        if remainingTime == 179 {
            bonnie.aggression += 1
            chica.aggression += 1
            foxy.aggression += 1
            print("Bonnie's aggression increased to \(bonnie.aggression).")
            print("Chica's aggression increased to \(chica.aggression).")
            print("Foxy's aggression increased to \(foxy.aggression).")
        }
        
        //Win on timeout
        if remainingTime == 0 {
            gameWon()
            print("You won!")
            return;
        }
        
        //Battery logic
        totalDrainRate = normalDrainRate
        if isLeftDoorClosed {totalDrainRate += doorDrainModifier}
        if isRightDoorClosed {totalDrainRate += doorDrainModifier}
        if isCameraOn {totalDrainRate += cameraDrainModifier}
        
        batteryLevel -= totalDrainRate
        
        if batteryLevel <= 0 {
            batteryLevel = 0
            if isPowerOutage == false {
                triggerPowerOutage()
            }
        }
    }
    
    //Start game timer function
    func startGameTimer(freddyai: Int, bonnieai: Int, chicaai: Int, foxyai: Int) {
        if isGameActive == false {
            isGameActive = true
            
            //Start timer
            gameTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(renderTime), userInfo: nil, repeats: true)
            
            //Setup animatronics
            if let showStage = locations["Show Stage"],
               let piratesCove = locations["Pirate's Cove"],
               let bonnie = bonnie,
               let chica = chica,
               let freddy = freddy,
               let foxy = foxy {
                _ = showStage.addAnimatronic(freddy)
                _ = showStage.addAnimatronic(bonnie)
                _ = showStage.addAnimatronic(chica)
                _ = piratesCove.addAnimatronic(foxy)
                
                //Set animatronic AI levels
                freddy.aggression = freddyai
                bonnie.aggression = bonnieai
                chica.aggression = chicaai
                foxy.aggression = foxyai
                
                //Start animatronic movement
                freddy.startMovementOpportunity()
                bonnie.startMovementOpportunity()
                chica.startMovementOpportunity()
                foxy.startMovementOpportunity()
            }
            
        }
    }
    
    //Trigger attack function
    func triggerAttack(from animatronic: Animatronic) {
        guard let freddy = freddy
        else {
            print("Existence error in triggerAttack!")
            return;
        }
        if animatronic.name == freddy.name {
            freddy.delayedAttack()
        }
        else {
            animatronic.attack()
        }
    }
    
    //Trigger power outage function
    func triggerPowerOutage() {
        guard let bonnie = bonnie,
              let chica = chica,
              let freddy = freddy,
              let foxy = foxy,
              let piratesCove = locations["Pirate's Cove"],
              let westDoor = locations["Outside West Door"],
              let showStage = locations["Show Stage"] else {
                  print("Existence error in triggerPowerOutage!")
                  return;
        }
        
        isPowerOutage = true
        isCameraOn = false
        isLeftDoorClosed = false
        isRightDoorClosed = false
        
        gameText = "The power ran out! You can't see anything!"
        
        freddy.aggression = 0
        _ = freddy.move(to: westDoor)
        bonnie.aggression = 0
        _ = bonnie.move(to: showStage)
        chica.aggression = 0
        _ = chica.move(to: showStage)
        foxy.aggression = 0
        _ = foxy.move(to: piratesCove)
        
        //Start outage sequence
        freddy.startOutageSequence()
    }
    
    //Check left door function
    func checkLeftDoor() {
        guard let bonnie = bonnie,
              let westDoor = locations["Outside West Door"] else {
                  print("Existence error in checkLeftDoor!")
                  return;
              }
        if bonnie.location == westDoor {
            //Update game text
            gameText = "You checked the left door. 🐰 is there!"
            //Indicate strong danger
            triggerDanger(level: 2)
        } else {
            //Update game text
            gameText = "You checked the left door. Looks clear."
        }
    }
    
    //Toggle left door function
    func toggleLeftDoor() {
        if isLeftDoorClosed == false {
            isLeftDoorClosed = true
            gameText = "You closed the left door."
        } else {
            isLeftDoorClosed = false
            gameText = "You opened the left door."
        }
    }
    
    //Check right door function
    func checkRightDoor() {
        guard let chica = chica,
              let eastDoor = locations["Outside East Door"] else {
                  print("Existence error in checkRightDoor!")
                  return;
              }
        if chica.location == eastDoor {
            //Update game text
            gameText = "You checked the right door. 🐤 is there!"
            //Indicate strong danger
            triggerDanger(level: 2)
        } else {
            //Update game text
            gameText = "You checked the right door. Looks clear."
        }
    }
    
    //Toggle right door function
    func toggleRightDoor() {
        if isRightDoorClosed == false {
            isRightDoorClosed = true
            gameText = "You closed the right door."
            
        } else {
            isRightDoorClosed = false
            gameText = "You opened the right door."
            
        }
    }
    //Access cameras function
    func accessCameras() {
        guard let bonnie = bonnie,
              let chica = chica,
              let foxy = foxy,
              let freddy = freddy,
              let office = locations["Office"] else {
                  print("Existence error in accessCameras!")
                  return;
        }
        
        if isCameraOn == false {
            isCameraOn = true
        }
        
        
        gameText = "Choose a camera to check..."
        
        //Stun Foxy while cameras are up
        //Clear the previous foxy stun timer if there is one
        if let foxyStunTimer = foxy.stunTimer {
            foxyStunTimer.invalidate()
        }
        foxy.stunned = true
        
        if bonnie.location == office {
            triggerAttack(from: bonnie)
        }
        if chica.location == office {
            triggerAttack(from: chica)
        }
        
        //Clear freddy's delayed attack timer if there is one
        if let freddyDelayedAttackTimer = freddy.delayedAttackTimer {
            freddyDelayedAttackTimer.invalidate()
        }
    }
    
    func getPiratesCoveMessage() -> String {
        guard let foxy = foxy else {
            print("Existence error in getPiratesCoveMessage!")
            return "Error";
        }
        let phases = [
        "🦊 is in a phase that doesn't exist.",
        "🦊 is hiding behind the curtain.",
        "🦊 is peeking from behind the curtain.",
        "🦊 is leaning out of the curtain.",
        "🦊 is gone!"]
        
        return phases[foxy.phase]
    }
    
    //Check camera function
    func checkCamera(locationstring: String) {
        guard let foxy = foxy,
              let freddy = freddy,
            let location = locations[locationstring] else {
            print("Existence error in checkCamera!")
            return;
        }
        lastCameraViewed = location
        
        var message = "You checked the \(location.name). "
        
        if location.name == "Pirate's Cove" {
            message += getPiratesCoveMessage()
            if foxy.phase == 3 {
                //Indicate slight danger
                triggerDanger(level: 1)
            } else if foxy.phase == 4 {
                //Indicate strong danger
                triggerDanger(level: 2)
            }
        } else {
            let animatronicIconList = location.getAnimatronicsIcons()
            let foxyIsSprinting = location.name == "West Hall" && foxy.phase == 4
            
            if foxyIsSprinting {
                message += "Foxy is sprinting down the hall!!"
                if let foxyAttackTimer = foxy.attackTimer {
                    foxyAttackTimer.invalidate()
                }
                foxy.triggerSprintAttack()
                //Indicate strong danger
                triggerDanger(level: 2)
                
            } else {
                animatronicIconList.forEach{icon in
                    message += "\(icon) is there. "}
                
                //Conditions for indicating slight danger
                if (location.name == "West Hall" && animatronicIconList.contains("🐰")) ||
                (location.name == "West Hall Corner" && animatronicIconList.contains("🐰")) ||
                (location.name == "East Hall" && animatronicIconList.contains("🐤")) ||
                (location.name == "East Hall Corner" && animatronicIconList.contains("🐤")) ||
                (location.name == "East Hall" && animatronicIconList.contains("🐻")) {
                    //Indicate slight danger
                    triggerDanger(level: 1)
                }
                
                //Conditions for indicating strong danger
                if location.name == "East Hall Corner" && animatronicIconList.contains("🐻") {
                    //Indicate strong danger
                    triggerDanger(level: 2)
                }
            }
        }
        
        gameText = message
        
        //If Freddy was spotted, stun him
        if location == freddy.location {
            if let freddyStunTimer = freddy.stunTimer {
                freddyStunTimer.invalidate()
            }
            
            freddy.stunned = true
            //print("Freddy was stunned.")
            freddy.wasViewed = true
        }
    }
    
    //Return to security room function
    func returnToSecurityRoom() {
        guard let bonnie = bonnie,
              let chica = chica,
              let foxy = foxy,
              let freddy = freddy,
              let office = locations["Office"] else {
            print("Existence error in returnToSecurityRoom!")
            return;
        }
        isCameraOn = false
        //Show the security room view and hide the camera view
        gameText = "You are in the security office."
        
        //Leave Foxy stunned for random time after leaving cameras
        let randomDuration = TimeInterval(Float.random(in: 0.83...16.6))
        //print("Foxy will un-stun in \(randomDuration) seconds.")
        //Clear the previous foxy stun timer if there is one
        if let foxyStunTimer = foxy.stunTimer {
            foxyStunTimer.invalidate()
        }
        //Set a new stun timer
        foxy.stunTimer = Timer.scheduledTimer(withTimeInterval: randomDuration, repeats: false) { _ in
            foxy.stunned = false
        }
        
        //Leave Freddy stunned for variable time after leaving cameras
        if freddy.stunned && freddy.wasViewed {
            let freddyStunDuration = TimeInterval(20 * (1 - freddy.aggression / 20))
            //print("Freddy will un-stun in \(freddyStunDuration) seconds.")
            //Clear the previous freddy stun timer if there is one
            if let freddyStunTimer = freddy.stunTimer {
                freddyStunTimer.invalidate()
            }
            //Set a new stun timer
            freddy.stunTimer = Timer.scheduledTimer(withTimeInterval: freddyStunDuration, repeats: false) { _ in
                freddy.stunned = false
            }
        }
        freddy.wasViewed = false
        
        if bonnie.location == office {
            triggerAttack(from: bonnie)
        }
        if chica.location == office {
            triggerAttack(from: chica)
        }
        if freddy.location == office {
            triggerAttack(from: freddy)
        }
    }
    
    func gameWon() {
        gameTimer?.invalidate()
        gameTimer = nil
        
        isGameActive = false
        isPowerOutage = false
        isLeftDoorClosed = false
        isRightDoorClosed = false
        isLeftDoorDisabled = false
        isRightDoorDisabled = false
        isCameraOn = false
        isVictory = true
        
        remainingTime = 0
        batteryLevel = 0.00
        totalDrainRate = 0.00
        gameText = "You safely left the pizzeria!"
                
        bonnie?.moveTimer?.invalidate()
        
        chica?.moveTimer?.invalidate()
        
        freddy?.moveTimer?.invalidate()
        freddy?.delayedAttackTimer?.invalidate()
        freddy?.outageMusicTimer?.invalidate()
        freddy?.outageAttackTimer?.invalidate()
        freddy?.outageWalkingTimer?.invalidate()
        
        foxy?.moveTimer?.invalidate()
        foxy?.attackTimer?.invalidate()
        foxy?.sprintTimer?.invalidate()
    }
    
    func gameOver() {
        gameTimer?.invalidate()
        gameTimer = nil
        
        isGameActive = false
        isPowerOutage = false
        isLeftDoorClosed = false
        isRightDoorClosed = false
        isLeftDoorDisabled = false
        isRightDoorDisabled = false
        isCameraOn = false
        
        remainingTime = 0
        batteryLevel = 0.00
        totalDrainRate = 0.00
        gameText = "X_X"
                
        bonnie?.moveTimer?.invalidate()
        chica?.moveTimer?.invalidate()
        freddy?.moveTimer?.invalidate()
        foxy?.moveTimer?.invalidate()
    }
    
    func resetGameState() {
        gameTimer?.invalidate()
        gameTimer = nil
        
        isGameActive = false
        isPowerOutage = false
        isLeftDoorClosed = false
        isRightDoorClosed = false
        isLeftDoorDisabled = false
        isRightDoorDisabled = false
        isCameraOn = false
        isVictory = false
        
        remainingTime = 535
        batteryLevel = 100.00
        totalDrainRate = 0.00
        gameText = "You are in the security office."
        lastAttacker = ""
        
        
        bonnie?.moveTimer?.invalidate()
        chica?.moveTimer?.invalidate()
        freddy?.moveTimer?.invalidate()
        foxy?.moveTimer?.invalidate()
        bonnie = nil
        chica = nil
        freddy = nil
        foxy = nil
    }
    
}
