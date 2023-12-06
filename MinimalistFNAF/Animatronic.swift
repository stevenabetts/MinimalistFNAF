//
//  Animatronic.swift
//  MinimalistFNAF
//
//  Created by Steve on 11/14/23.
//

import Foundation

class Animatronic {
    let name: String
    let icon: String
    weak var location: Location?
    var stunned: Bool
    var aggression: Int
    var moveFrequency: TimeInterval
    var phase: Int
    private var movementRules: [Location: [Location]]
    weak var gameState: GameState?
    
    init(name: String, icon: String, aggression: Int, moveFrequency: TimeInterval, gameState: GameState){
        self.name = name
        self.icon = icon
        self.stunned = false
        self.aggression = aggression
        self.moveFrequency = moveFrequency
        self.phase = 1
        self.movementRules = [:]
        self.gameState = gameState
    }
    
    func addMovementRule(currentLocation: Location, nextLocations: [Location]){
        movementRules[currentLocation] = nextLocations
    }
    
    func getPossibleMoves() -> [Location] {
        guard let currentLocation = location else {
            return [] //No current location means no possible moves!
        }
        return movementRules[currentLocation] ?? []
    }
    
    func move(to newLocation: Location) -> Bool {
        if let currentLocation = location {
            currentLocation.removeAnimatronic(self)
        }
        if newLocation.addAnimatronic(self){
            location = newLocation
            print("\(name) moved to \(newLocation.name)")
            return true
        } else {
            print("\(name) could not move, \(newLocation.name) was full.")
            return false
        }
    }
    
    func pickLocationToMove() {
        let possibleMoves = getPossibleMoves()
        if let nextLocation = possibleMoves.randomElement() {
            _ = self.move(to: nextLocation)
        } else {
            print("\(name) has nowhere to go!")
        }
    }
    
    func attack() {
        if let gameState = gameState {
            gameState.gameOver()
            gameState.lastAttacker = self.name
        }
    }
}

class Freddy: Animatronic {
    init(aggression: Int, gameState: GameState) {
        wasViewed = false
        super.init(name: "Freddy", icon: "🐻", aggression: aggression, moveFrequency: 3.02, gameState: gameState)
        // Setup movement rules
        initMovementRules(using: gameState.locations)
    }
    private func initMovementRules(using locations: [String: Location]) {
        if let showStage = locations["Show Stage"],
            let diningArea = locations["Dining Area"],
            let restrooms = locations["Restrooms"],
            let kitchen = locations["Kitchen"],
            let eastHall = locations["East Hall"],
            let eastCorner = locations["East Hall Corner"],
            let office = locations["Office"] {
                addMovementRule(currentLocation: showStage, nextLocations: [diningArea])
                addMovementRule(currentLocation: diningArea, nextLocations: [restrooms])
                addMovementRule(currentLocation: restrooms, nextLocations: [kitchen])
                addMovementRule(currentLocation: kitchen, nextLocations: [eastHall])
                addMovementRule(currentLocation: eastHall, nextLocations: [eastCorner])
                addMovementRule(currentLocation: eastCorner, nextLocations: [office])
            }
    }
    
    var wasViewed: Bool
    var moveTimer: Timer?
    var stunTimer: Timer?
    var outageMusicTimer: Timer?
    var outageWalkingTimer: Timer?
    var outageAttackTimer: Timer?
    var delayedAttackTimer: Timer?
    
    func startMovementOpportunity() {
        moveTimer = Timer.scheduledTimer(withTimeInterval: moveFrequency, repeats: true) { [weak self] _ in
            self?.tryMove()
        }
    }
    
    func tryMove() {
        guard let gameState = gameState,
              let bonnie = gameState.bonnie,
              let chica = gameState.chica,
              let showStage = gameState.locations["Show Stage"],
              let eastHall = gameState.locations["East Hall"],
              let eastCorner = gameState.locations["East Hall Corner"] else {
            print("Existence error in tryMove!")
            return;
        }
        
        let randomNumber = Int.random(in: 1...20)
        //print("\(name) with aggression \(aggression) rolled \(randomNumber)")
        
        if aggression >= randomNumber {
            if self.stunned == true {
                print("Freddy is stunned and can't advance!")
            } else if self.location == showStage && (bonnie.location == showStage || chica.location == showStage){
                print("Freddy won't move until Bonnie and Chica leave the stage.")
            } else if self.location == eastCorner && gameState.isRightDoorClosed == true {
                _ = self.move(to: eastHall)
            } else if self.location == eastCorner && gameState.isCameraOn == false {
                print("Freddy won't enter the office while the cameras are down.")
            } else if self.location == eastCorner && gameState.lastCameraViewed == eastCorner {
                print("Freddy won't enter the office while cam-stalled.")
            } else {
                self.pickLocationToMove()
                //Indicate freddy movement
            }
        } else {
            //print("Freddy failed to move.")
        }
    }
    
    func startOutageSequence() {
        //First phase: office is dark
        var elapsedTime = 0
        self.outageMusicTimer = Timer.scheduledTimer(withTimeInterval: 5, repeats: true) {
            [weak self] _ in
            elapsedTime += 5
            if Double.random(in: 0..<1) < 0.2 || elapsedTime >= 20 {
                self?.gameState?.gameText = "🐻 started playing his music box..."
                self?.outageMusicTimer?.invalidate()
                self?.freddyPlaysMusic()
            }
        }
    }
    
    func freddyPlaysMusic() {
        //Second phase: Freddy plays music box
        var elapsedTime = 0
        self.outageWalkingTimer = Timer.scheduledTimer(withTimeInterval: 5, repeats: true) {
            [weak self] _ in
            elapsedTime += 5
            if Double.random(in: 0..<1) < 0.2 || elapsedTime >= 20 {
                self?.gameState?.gameText = "The music stopped. 🐻 is walking into the office..."
                self?.outageWalkingTimer?.invalidate()
                self?.freddyWalks()
            }
        }
    }
    
    func freddyWalks() {
        if let office = gameState?.locations["Office"] {
            _ = self.move(to: office)
            var elapsedTime = 0
            self.outageAttackTimer = Timer.scheduledTimer(withTimeInterval: 2, repeats: true) {
                [weak self] _ in
                elapsedTime += 2
                if Double.random(in: 0..<1) < 0.2 {
                    self?.outageAttackTimer?.invalidate()
                    self?.attack()
                }
            }
        } else {
            print("Existence error in freddyWalks!")
        }
    }
    
    //Delayed attack when Freddy enters office: 20% chance every second
    func delayedAttack() {
        self.delayedAttackTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) {
            [weak self] _ in
            if Double.random(in: 0..<1) < 0.2 {
                self?.delayedAttackTimer?.invalidate()
                self?.attack()
            }
        }
    }
    
    deinit {
        //print("Destroying Freddy")
        stunTimer?.invalidate()
        moveTimer?.invalidate()
        delayedAttackTimer?.invalidate()
        outageMusicTimer?.invalidate()
        outageAttackTimer?.invalidate()
        outageWalkingTimer?.invalidate()
        
    }
}

class Bonnie: Animatronic {
    init(aggression: Int, gameState: GameState) {
        super.init(name: "Bonnie", icon: "🐰", aggression: aggression, moveFrequency: 4.97, gameState: gameState)
        // Setup movement rules
        initMovementRules(using: gameState.locations)
    }

    private func initMovementRules(using locations: [String: Location]) {
        if let showStage = locations["Show Stage"],
           let diningArea = locations["Dining Area"],
           let backstage = locations["Backstage"],
           let westHall = locations["West Hall"],
           let supplyCloset = locations["Supply Closet"],
           let westCorner = locations["West Hall Corner"],
           let westDoor = locations["Outside West Door"],
           let office = locations["Office"] {
                addMovementRule(currentLocation: showStage, nextLocations: [diningArea, backstage])
                addMovementRule(currentLocation: diningArea, nextLocations: [backstage, westHall, supplyCloset, westCorner])
                addMovementRule(currentLocation: backstage, nextLocations: [diningArea, westHall])
                addMovementRule(currentLocation: westHall, nextLocations: [supplyCloset, westCorner, westDoor, diningArea, backstage])
                addMovementRule(currentLocation: supplyCloset, nextLocations: [westHall, westCorner, diningArea])
                addMovementRule(currentLocation: westCorner, nextLocations: [westHall, westDoor, supplyCloset, diningArea])
                addMovementRule(currentLocation: westDoor, nextLocations: [office])
        }
    }

    var moveTimer: Timer?

    func startMovementOpportunity() {
        moveTimer = Timer.scheduledTimer(withTimeInterval: moveFrequency, repeats: true) { [weak self] _ in
            self?.tryMove()
        }
    }

    func tryMove() {
        guard let gameState = gameState,
              let location = location,
              let diningArea = gameState.locations["Dining Area"],
              let westHall = gameState.locations["West Hall"],
              let westCorner = gameState.locations["West Hall Corner"],
              let westDoor = gameState.locations["Outside West Door"],
              let office = gameState.locations["Office"] else {
            print("Existence error in tryMove!")
            return
        }

        let randomNumber = Int.random(in: 1...20)
        //print("\(name) rolled \(randomNumber)")

        if aggression >= randomNumber {
            if location == westDoor && gameState.isLeftDoorClosed == true {
                _ = self.move(to: diningArea)
                // Indicate near movement
                print("Bonnie was blocked and reset to dining area.")
            } else {
                let startLocation = location
                pickLocationToMove()

                if location == office {
                    // Disable left door buttons
                    gameState.disableLeftDoor()
                }

                // Handle near movement indication
                if [westHall, westCorner].contains(startLocation) {
                    // Indicate near movement
                }
                if [westHall, westCorner, westDoor].contains(location) {
                    // Indicate near movement
                }
            }
        } else {
            //print("Bonnie failed to move.")
        }
    }

    
    deinit {
        //print("Destroying Bonnie")
        moveTimer?.invalidate()
    }
}

class Chica: Animatronic {
    init(aggression: Int, gameState: GameState){
        super.init(name: "Chica", icon: "🐤", aggression: aggression, moveFrequency: 4.98, gameState: gameState)
        //Setup movement rules
        initMovementRules(using: gameState.locations)
        
    }
    
    private func initMovementRules(using locations: [String: Location]) {
        if let showStage = locations["Show Stage"],
            let diningArea = locations["Dining Area"],
            let restrooms = locations["Restrooms"],
            let kitchen = locations["Kitchen"],
            let eastHall = locations["East Hall"],
            let eastCorner = locations["East Hall Corner"],
            let eastDoor = locations["Outside East Door"],
            let office = locations["Office"] {
                addMovementRule(currentLocation: showStage, nextLocations: [diningArea])
                addMovementRule(currentLocation: diningArea, nextLocations: [restrooms, kitchen, eastHall])
                addMovementRule(currentLocation: restrooms, nextLocations: [diningArea])
                addMovementRule(currentLocation: kitchen, nextLocations: [diningArea])
                addMovementRule(currentLocation: eastHall, nextLocations: [diningArea, eastCorner, eastDoor])
                addMovementRule(currentLocation: eastCorner, nextLocations: [eastHall, eastDoor])
                addMovementRule(currentLocation: eastDoor, nextLocations: [office])
            }
    }
    
    var moveTimer: Timer?
    
    func startMovementOpportunity() {
            moveTimer = Timer.scheduledTimer(withTimeInterval: moveFrequency, repeats: true) { [weak self] _ in
                self?.tryMove()
            }
    }
    
    func tryMove(){
        guard let gameState = gameState,
              let location = location,
              let diningArea = gameState.locations["Dining Area"],
              let kitchen = gameState.locations["Kitchen"],
              let eastHall = gameState.locations["East Hall"],
              let eastCorner = gameState.locations["East Hall Corner"],
              let eastDoor = gameState.locations["Outside East Door"],
              let office = gameState.locations["Office"] else {
            print("Existence error in tryMove!")
            return;
        }
              
        
        let randomNumber = Int.random(in: 1...20)
        //print("\(name) rolled \(randomNumber)")
        
        if aggression >= randomNumber {
            if location == eastDoor,
               gameState.isRightDoorClosed == true {
                _ = self.move(to: diningArea)
                //Indicate near movement
                print("Chica was blocked and reset to dining area.")
            }
            else {
                let startLocation = location
                pickLocationToMove()
                
                if location == office {
                    //Disable right door buttons
                    gameState.disableRightDoor()
                }
                //Handle near movement indication
                if [eastHall, eastCorner].contains(startLocation){
                    //Indicate near movement
                }
                if [eastHall, eastCorner].contains(location){
                    //indicate near movement
                }
                if location == kitchen {
                    //indicate kitchen movement
                }
            }
        } else {
            //print("Chica failed to move.")
        }
    }
    
    
    deinit {
        //print("Destroying Chica")
        moveTimer?.invalidate()
    }}

class Foxy: Animatronic {
    init(aggression: Int, gameState: GameState){
        foxyAttackDrain = 1
        super.init(name: "Foxy", icon: "🦊", aggression: aggression, moveFrequency: 5.01, gameState: gameState)
        //Setup movement rules
        initMovementRules(using: gameState.locations)
        
    }
    private func initMovementRules(using locations: [String: Location]) {
        if let piratesCove = locations["Pirate's Cove"],
            let westHall = locations["West Hall"] {
                addMovementRule(currentLocation: piratesCove, nextLocations: [westHall])
            }
    }
    
    var moveTimer: Timer?
    var stunTimer: Timer?
    var attackTimer: Timer?
    var sprintTimer: Timer?
    var foxyAttackDrain: Float
    
    func startMovementOpportunity() {
            moveTimer = Timer.scheduledTimer(withTimeInterval: moveFrequency, repeats: true) { [weak self] _ in
                self?.tryMove()
            }
    }
    
    func attackDoor() {
        guard let piratesCove = gameState?.locations["Pirate's Cove"]
        else {
            print("Existence error in attackDoor!")
            return;
        }
        
        if gameState?.isLeftDoorClosed == true {
            print("Foxy banged on the left door, reset to Pirate's cove.")
            //Flash the UI
            gameState?.gameText = "🦊 banged on the left door!"
            gameState?.triggerDanger(level: 1)
            
            gameState?.drainBattery(by: foxyAttackDrain)
            foxyAttackDrain += 4
            _ = self.move(to: piratesCove)
            self.phase = 1
        }
        else if gameState?.isPowerOutage == true {
            print("Foxy will not attack because the power is out.")
            _ = self.move(to: piratesCove)
            self.phase = 1
        }
        else {
            self.attack()
        }
    }
    
    func triggerSprintAttack(){
        if let westHall = gameState?.locations["West Hall"] {
            _ = self.move(to: westHall)
            print("Foxy is sprinting down the west hall.")
            sprintTimer = Timer.scheduledTimer(withTimeInterval: 2.8, repeats: false) {
                [weak self] _ in self?.attackDoor()
            }
        }
    }
    
    func startAttackCountdown() {
        let randomTimer = Float.random(in: 0.85...26.00)
        print("Foxy will attack in \(randomTimer) seconds.")
        attackTimer = Timer.scheduledTimer(withTimeInterval: TimeInterval(randomTimer), repeats: false) {[weak self] _ in self?.triggerSprintAttack()}
    }
    
    func tryMove() {
        let randomNumber = Int.random(in: 1...20)
        //print("\(name) rolled \(randomNumber)")
        
        if aggression >= randomNumber {
            if self.stunned == true {
                print("Foxy is stunned and can't advance!")
            }
            else {
                if self.phase < 4 {
                    self.phase += 1
                    print("Foxy advanced to phase \(self.phase).")
                    if self.phase == 4 {
                        self.startAttackCountdown()
                    }
                } else {
                    print("Foxy can't advance any further.")
                }
            }
        } else {
            //print("Foxy failed to move.")
        }
    }
    
    deinit {
        //print("Destroying Foxy")
        moveTimer?.invalidate()
        stunTimer?.invalidate()
        attackTimer?.invalidate()
        sprintTimer?.invalidate()
    }
}
