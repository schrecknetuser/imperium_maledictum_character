//
//  SkillModel.swift
//  ImperiumMaledictumCharacter
//
//  Created by User on 11.01.2025.
//

import Foundation
import SwiftData

@Model
class Skill {
    var name: String
    var relatedCharacteristic: String
    var advances: Int
    var specializationsData: String // JSON dictionary [String: Int]
    
    var specializations: [String: Int] {
        get {
            guard let data = specializationsData.data(using: .utf8),
                  let decoded = try? JSONDecoder().decode([String: Int].self, from: data) else {
                return [:]
            }
            return decoded
        }
        set {
            if let encoded = try? JSONEncoder().encode(newValue) {
                specializationsData = String(data: encoded, encoding: .utf8) ?? ""
            }
        }
    }
    
    func getValue(characteristicValue: Int) -> Int {
        return characteristicValue + (5 * advances)
    }
    
    func getSpecializationValue(name: String, characteristicValue: Int) -> Int {
        let skillValue = getValue(characteristicValue: characteristicValue)
        let specializationAdvances = specializations[name] ?? 0
        return skillValue + (5 * specializationAdvances)
    }
    
    init(name: String, relatedCharacteristic: String, advances: Int = 0) {
        self.name = name
        self.relatedCharacteristic = relatedCharacteristic
        self.advances = advances
        self.specializationsData = ""
    }
}

// MARK: - Skill Constants
struct SkillDefinitions {
    static let definitions: [String: String] = [
        "Athletics": CharacteristicNames.strength,
        "Awareness": CharacteristicNames.perception,
        "Dexterity": CharacteristicNames.agility,
        "Discipline": CharacteristicNames.willpower,
        "Fortitude": CharacteristicNames.toughness,
        "Intuition": CharacteristicNames.perception,
        "Linguistics": CharacteristicNames.intelligence,
        "Logic": CharacteristicNames.intelligence,
        "Lore": CharacteristicNames.intelligence,
        "Medicae": CharacteristicNames.intelligence,
        "Melee": CharacteristicNames.weaponSkill,
        "Navigation": CharacteristicNames.intelligence,
        "Piloting": CharacteristicNames.agility,
        "Presence": CharacteristicNames.willpower,
        "Psychic Mastery": CharacteristicNames.willpower,
        "Ranged": CharacteristicNames.ballisticSkill,
        "Rapport": CharacteristicNames.fellowship,
        "Reflexes": CharacteristicNames.agility,
        "Stealth": CharacteristicNames.agility,
        "Tech": CharacteristicNames.intelligence
    ]
    
    static let allSkills = Array(definitions.keys).sorted()
}

struct SkillSpecializations {
    static let specializations: [String: [String]] = [
        "Athletics": ["Climbing", "Might", "Riding", "Running", "Swimming"],
        "Awareness": ["Sight", "Smell", "Hearing", "Taste", "Touch", "Psyniscience"],
        "Dexterity": ["Lock Picking", "Pickpocket", "Sleight of Hand", "Defuse"],
        "Discipline": ["Composure", "Fear", "Psychic"],
        "Fortitude": ["Endurance", "Pain", "Poison"],
        "Intuition": ["Human", "Group", "Surroundings"],
        "Linguistics": ["Cypher", "High Gothic", "Forbidden"],
        "Logic": ["Evaluation", "Investigation"],
        "Lore": ["Academics", "Adeptus Terra", "Planet", "Sector", "Theology", "Forbidden"],
        "Medicae": ["Animal", "Human", "Forbidden"],
        "Melee": ["Brawling", "One-handed", "Two-handed"],
        "Navigation": ["Surface", "Tracking", "Void", "Warp"],
        "Piloting": ["Aeronautica", "Civilian", "Military", "Minor Voidship", "Major Voidship"],
        "Presence": ["Interrogation", "Intimidation", "Leadership"],
        "Psychic Mastery": ["Biomancy", "Divination", "Pyromancy", "Telekinesis", "Telepathy", "Various"],
        "Ranged": ["Long Guns", "Ordnance", "Pistols", "Thrown"],
        "Rapport": ["Animals", "Charm", "Deception", "Haggle", "Inquiry"],
        "Reflexes": ["Acrobatics", "Balance", "Dodge"],
        "Stealth": ["Conceal", "Hide", "Move Silently"],
        "Tech": ["Augmetics", "Engineering", "Security"]
    ]
    
    static func getSpecializations(for skill: String) -> [String] {
        return specializations[skill] ?? []
    }
}