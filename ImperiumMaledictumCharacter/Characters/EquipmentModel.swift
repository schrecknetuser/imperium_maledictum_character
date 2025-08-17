//
//  EquipmentModel.swift
//  ImperiumMaledictumCharacter
//
//  Created by User on 11.01.2025.
//

import Foundation

class Equipment: Codable {
    var name: String
    var equipmentDescription: String
    var encumbrance: Int
    var cost: Int
    var availability: String
    var qualitiesData: String // JSON array of strings
    var flawsData: String // JSON array of strings
    var traitsData: String // JSON array of EquipmentTrait
    
    var qualities: [String] {
        get {
            guard let data = qualitiesData.data(using: .utf8),
                  let decoded = try? JSONDecoder().decode([String].self, from: data) else {
                return []
            }
            return decoded
        }
        set {
            if let encoded = try? JSONEncoder().encode(newValue) {
                qualitiesData = String(data: encoded, encoding: .utf8) ?? ""
            }
        }
    }
    
    var flaws: [String] {
        get {
            guard let data = flawsData.data(using: .utf8),
                  let decoded = try? JSONDecoder().decode([String].self, from: data) else {
                return []
            }
            return decoded
        }
        set {
            if let encoded = try? JSONEncoder().encode(newValue) {
                flawsData = String(data: encoded, encoding: .utf8) ?? ""
            }
        }
    }
    
    var traits: [EquipmentTrait] {
        get {
            guard let data = traitsData.data(using: .utf8),
                  let decoded = try? JSONDecoder().decode([EquipmentTrait].self, from: data) else {
                return []
            }
            return decoded
        }
        set {
            if let encoded = try? JSONEncoder().encode(newValue) {
                traitsData = String(data: encoded, encoding: .utf8) ?? ""
            }
        }
    }
    
    init(name: String, equipmentDescription: String = "", encumbrance: Int = 0, cost: Int = 0, availability: String = "Common") {
        self.name = name
        self.equipmentDescription = equipmentDescription
        self.encumbrance = encumbrance
        self.cost = cost
        self.availability = availability
        self.qualitiesData = ""
        self.flawsData = ""
        self.traitsData = ""
    }
}

struct EquipmentTrait: Codable {
    var name: String
    var traitDescription: String
    var parameter: String
    
    var displayName: String {
        return parameter.isEmpty ? name : "\(name) (\(parameter))"
    }
    
    init(name: String, traitDescription: String = "", parameter: String = "") {
        self.name = name
        self.traitDescription = traitDescription
        self.parameter = parameter
    }
}

// MARK: - Equipment Constants
struct EquipmentQualities {
    static let lightweight = "Lightweight"
    static let masterCrafted = "Master Crafted"
    static let ornamental = "Ornamental"
    static let durable = "Durable"
    
    static let all = [lightweight, masterCrafted, ornamental, durable]
}

struct EquipmentFlaws {
    static let bulky = "Bulky"
    static let shoddy = "Shoddy"
    static let ugly = "Ugly"
    static let unreliable = "Unreliable"
    
    static let all = [bulky, shoddy, ugly, unreliable]
}

struct EquipmentTraitNames {
    static let blast = "Blast"
    static let burst = "Burst"
    static let close = "Close"
    static let defensive = "Defensive"
    static let flamer = "Flamer"
    static let heavy = "Heavy"
    static let ineffective = "Ineffective"
    static let inflict = "Inflict"
    static let loud = "Loud"
    static let penetrating = "Penetrating"
    static let rapidFire = "Rapid Fire"
    static let reach = "Reach"
    static let reliable = "Reliable"
    static let rend = "Rend"
    static let shield = "Shield"
    static let spread = "Spread"
    static let subtle = "Subtle"
    static let supercharge = "Supercharge"
    static let thrown = "Thrown"
    static let twoHanded = "Two-Handed"
    static let unstable = "Unstable"
    
    static let all = [
        blast, burst, close, defensive, flamer, heavy, ineffective,
        inflict, loud, penetrating, rapidFire, reach, reliable, rend,
        shield, spread, subtle, supercharge, thrown, twoHanded, unstable
    ]
}

struct AvailabilityLevels {
    static let common = "Common"
    static let rare = "Rare"
    static let scarce = "Scarce"
    static let exotic = "Exotic"
    
    static let all = [common, rare, scarce, exotic]
}
