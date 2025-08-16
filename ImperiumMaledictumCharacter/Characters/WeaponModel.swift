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