//
//  Location.swift
//  MinimalistFNAF
//
//  Created by Steve on 11/14/23.
//

import Foundation

class Location: Hashable {
    let name: String
    var animatronics: [Animatronic]
    let capacity: Int
    
    init(name: String, capacity: Int){
        self.name = name
        self.animatronics = []
        self.capacity = capacity
    }
    
    func addAnimatronic(_ animatronic: Animatronic) -> Bool {
        if animatronics.count < capacity {
            animatronics.append(animatronic)
            animatronic.location = self
            return true
        } else {
            print("Can't add, Location is full")
            return false
        }
    }
    
    func removeAnimatronic(_ animatronic: Animatronic) {
        animatronics.removeAll {$0 === animatronic}
    }
    
    func getAnimatronicsNames() -> [String] {
        return animatronics.map {$0.name}
    }
    
    func getAnimatronicsIcons() -> [String] {
        return animatronics.map {$0.icon}
    }
    
    static func == (lhs: Location, rhs: Location) -> Bool {
        return lhs.name == rhs.name
    }
    
    func hash(into hasher: inout Hasher){
        hasher.combine(name)
    }
}
