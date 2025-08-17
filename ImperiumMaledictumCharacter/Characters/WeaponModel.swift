//
//  WeaponModel.swift
//  ImperiumMaledictumCharacter
//
//  Created by User on 11.01.2025.
//

import Foundation
import SwiftData

@Model
class Weapon {
    var name: String
    var specialization: String
    var damage: String
    var range: String // short/medium/long
    var magazine: Int
    var encumbrance: Int
    var availability: String
    var cost: Int
    var weaponTraitsData: String // JSON array of WeaponTrait
    var modificationsData: String // JSON array of strings
    var qualitiesData: String // JSON array of strings
    var flawsData: String // JSON array of strings
    
    var weaponTraits: [WeaponTrait] {
        get {
            guard let data = weaponTraitsData.data(using: .utf8),
                  let decoded = try? JSONDecoder().decode([WeaponTrait].self, from: data) else {
                return []
            }
            return decoded
        }
        set {
            if let encoded = try? JSONEncoder().encode(newValue) {
                weaponTraitsData = String(data: encoded, encoding: .utf8) ?? ""
            }
        }
    }
    
    var modifications: [String] {
        get {
            guard let data = modificationsData.data(using: .utf8),
                  let decoded = try? JSONDecoder().decode([String].self, from: data) else {
                return []
            }
            return decoded
        }
        set {
            if let encoded = try? JSONEncoder().encode(newValue) {
                modificationsData = String(data: encoded, encoding: .utf8) ?? ""
            }
        }
    }
    
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
    
    init(name: String, specialization: String = "", damage: String = "", range: String = "Short", magazine: Int = 0, encumbrance: Int = 0, availability: String = "Common", cost: Int = 0) {
        self.name = name
        self.specialization = specialization
        self.damage = damage
        self.range = range
        self.magazine = magazine
        self.encumbrance = encumbrance
        self.availability = availability
        self.cost = cost
        self.weaponTraitsData = ""
        self.modificationsData = ""
        self.qualitiesData = ""
        self.flawsData = ""
    }
}

struct WeaponTrait: Codable {
    var name: String
    var description: String
    var parameter: String
    
    var displayName: String {
        return parameter.isEmpty ? name : "\(name) (\(parameter))"
    }
    
    init(name: String, description: String = "", parameter: String = "") {
        self.name = name
        self.description = description
        self.parameter = parameter
    }
}

// MARK: - Weapon Constants
struct WeaponRanges {
    static let short = "Short"
    static let medium = "Medium"
    static let long = "Long"
    
    static let all = [short, medium, long]
}

struct WeaponModifications {
    static let exterminatorCartridge = "Exterminator Cartridge"
    static let meleeAttachment = "Melee Attachment"
    static let monoEdge = "Mono-edge"
    static let photoSight = "Photo Sight"
    static let laserSight = "Laser Sight"
    static let telescopicSight = "Telescopic Sight"
    static let backpackAmmoSupply = "Backpack Ammo Supply"
    static let bipod = "Bipod"
    static let fireSelector = "Fire Selector"
    static let silencer = "Silencer"
    
    static let all = [
        exterminatorCartridge, meleeAttachment, monoEdge, photoSight,
        laserSight, telescopicSight, backpackAmmoSupply, bipod,
        fireSelector, silencer
    ]
}

struct WeaponSpecializations {
    static let none = "None"
    static let oneHanded = "One-handed"
    static let twoHanded = "Two-handed"
    static let brawling = "Brawling"
    static let pistol = "Pistol"
    static let longGun = "Long Gun"
    static let ordnance = "Ordnance"
    
    static let all = [none, oneHanded, twoHanded, brawling, pistol, longGun, ordnance]
}

struct WeaponTraitNames {
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
    static let twoHanded = "Two-handed"
    static let unstable = "Unstable"
    
    static let all = [
        blast, burst, close, defensive, flamer, heavy, ineffective,
        inflict, loud, penetrating, rapidFire, reach, reliable, rend,
        shield, spread, subtle, supercharge, thrown, twoHanded, unstable
    ]
}