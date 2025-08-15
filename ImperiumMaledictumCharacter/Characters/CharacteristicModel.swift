//
//  CharacteristicModel.swift
//  ImperiumMaledictumCharacter
//
//  Created by User on 11.01.2025.
//

import Foundation
import SwiftData

@Model
class Characteristic {
    var name: String
    var initialValue: Int
    var advances: Int
    
    var derivedValue: Int {
        return initialValue + (5 * advances)
    }
    
    init(name: String, initialValue: Int = 20, advances: Int = 0) {
        self.name = name
        self.initialValue = initialValue
        self.advances = advances
    }
}

// MARK: - Characteristic Names
struct CharacteristicNames {
    static let weaponSkill = "Weapon Skill"
    static let ballisticSkill = "Ballistic Skill"
    static let strength = "Strength"
    static let toughness = "Toughness"
    static let agility = "Agility"
    static let intelligence = "Intelligence"
    static let willpower = "Willpower"
    static let fellowship = "Fellowship"
    static let perception = "Perception"
    
    static let allCharacteristics = [
        weaponSkill, ballisticSkill, strength, toughness, agility,
        intelligence, willpower, fellowship, perception
    ]
}