//
//  WeaponModel.swift
//  ImperiumMaledictumCharacter
//
//  Created by User on 11.01.2025.
//

import Foundation

class Weapon: Codable {
    var id: UUID
    var name: String
    var weaponDescription: String
    var category: String // melee/ranged/grenades
    var specialization: String
    var damage: String
    var range: String // short/medium/long/extreme
    var magazine: Int
    var encumbrance: Int
    var availability: String
    var cost: Int
    var weaponTraitsData: String // JSON array of WeaponTrait
    var modificationsData: String // JSON array of strings
    var qualitiesData: String // JSON array of strings
    var flawsData: String // JSON array of strings
    
    // For backward compatibility with Weapon objects that don't have IDs
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Try to decode ID, if it doesn't exist, generate a new one
        if let decodedId = try? container.decode(UUID.self, forKey: .id) {
            self.id = decodedId
        } else {
            self.id = UUID()
        }
        
        self.name = try container.decode(String.self, forKey: .name)
        
        // Try to decode weaponDescription, if it doesn't exist, use empty string
        if let decodedDescription = try? container.decode(String.self, forKey: .weaponDescription) {
            self.weaponDescription = decodedDescription
        } else {
            self.weaponDescription = ""
        }
        
        self.category = try container.decode(String.self, forKey: .category)
        self.specialization = try container.decode(String.self, forKey: .specialization)
        self.damage = try container.decode(String.self, forKey: .damage)
        self.range = try container.decode(String.self, forKey: .range)
        self.magazine = try container.decode(Int.self, forKey: .magazine)
        self.encumbrance = try container.decode(Int.self, forKey: .encumbrance)
        self.availability = try container.decode(String.self, forKey: .availability)
        self.cost = try container.decode(Int.self, forKey: .cost)
        self.weaponTraitsData = try container.decode(String.self, forKey: .weaponTraitsData)
        self.modificationsData = try container.decode(String.self, forKey: .modificationsData)
        self.qualitiesData = try container.decode(String.self, forKey: .qualitiesData)
        self.flawsData = try container.decode(String.self, forKey: .flawsData)
    }
    
    enum CodingKeys: String, CodingKey {
        case id, name, weaponDescription, category, specialization, damage, range, magazine, encumbrance, availability, cost, weaponTraitsData, modificationsData, qualitiesData, flawsData
    }
    
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
    
    init(name: String, weaponDescription: String = "", category: String = WeaponCategories.ranged, specialization: String = WeaponSpecializations.none, damage: String = "", range: String = "Short", magazine: Int = 0, encumbrance: Int = 0, availability: String = "Common", cost: Int = 0) {
        self.id = UUID()
        self.name = name
        self.weaponDescription = weaponDescription
        self.category = category
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
    
    // Migration method to handle existing weapons without category
    func migrateCategory() {
        if category.isEmpty {
            // Try to determine category from weapon name or specialization
            let name = self.name.lowercased()
            if name.contains("grenade") || name.contains("explosive") || name.contains("mine") {
                category = WeaponCategories.grenades
            } else if specialization == WeaponSpecializations.pistol || 
                      specialization == WeaponSpecializations.longGun || 
                      specialization == WeaponSpecializations.ordnance {
                category = WeaponCategories.ranged
            } else if specialization == WeaponSpecializations.oneHanded || 
                      specialization == WeaponSpecializations.twoHanded || 
                      specialization == WeaponSpecializations.brawling {
                category = WeaponCategories.melee
            } else {
                // Default to ranged for unknown
                category = WeaponCategories.ranged
            }
        }
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
    static let extreme = "Extreme"
    
    static let all = [short, medium, long, extreme]
}

struct WeaponCategories {
    static let melee = "Melee"
    static let ranged = "Ranged"
    static let grenades = "Grenades & Explosives"
    
    static let all = [melee, ranged, grenades]
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

// MARK: - Weapon Template System
struct WeaponTemplate {
    var name: String
    var description: String
    var category: String
    var specialization: String
    var damage: String
    var range: String
    var magazine: Int
    var encumbrance: Int
    var cost: Int
    var availability: String
    var traits: [String]
    
    init(name: String, description: String = "", category: String, specialization: String, damage: String, range: String = WeaponRanges.short, magazine: Int = 0, encumbrance: Int = 0, cost: Int = 0, availability: String = "Common", traits: [String] = []) {
        self.name = name
        self.description = description
        self.category = category
        self.specialization = specialization
        self.damage = damage
        self.range = range
        self.magazine = magazine
        self.encumbrance = encumbrance
        self.cost = cost
        self.availability = availability
        self.traits = traits
    }
    
    func createWeapon() -> Weapon {
        let weapon = Weapon(
            name: name,
            weaponDescription: description,
            category: category,
            specialization: specialization,
            damage: damage,
            range: range,
            magazine: magazine,
            encumbrance: encumbrance,
            availability: availability,
            cost: cost
        )
        weapon.weaponTraits = traits.map { WeaponTrait(name: $0) }
        return weapon
    }
}

struct WeaponTemplateDefinitions {
    // MARK: - Ranged Weapons
    static let rangedWeapons: [WeaponTemplate] = [
        // Bolt Weapons
        WeaponTemplate(name: "Bolt Pistol", category: WeaponCategories.ranged, specialization: WeaponSpecializations.pistol, damage: "8", range: WeaponRanges.medium, magazine: 2, encumbrance: 1, cost: 4000, availability: "Scarce", traits: ["Burst", "Close", "Loud", "Penetrating (4)", "Spread"]),
        WeaponTemplate(name: "Boltgun", category: WeaponCategories.ranged, specialization: WeaponSpecializations.longGun, damage: "8", range: WeaponRanges.long, magazine: 4, encumbrance: 2, cost: 5000, availability: "Scarce", traits: ["Loud", "Penetrating (4)", "Rapid Fire (2)", "Spread", "Two-handed"]),
        WeaponTemplate(name: "Heavy Bolter", category: WeaponCategories.ranged, specialization: WeaponSpecializations.ordnance, damage: "10", range: WeaponRanges.long, magazine: 6, encumbrance: 3, cost: 9000, availability: "Rare", traits: ["Heavy (4)", "Penetrating (5)", "Loud", "Rapid Fire (3)", "Spread", "Two-handed"]),
        
        // Flame Weapons
        WeaponTemplate(name: "Hand Flamer", category: WeaponCategories.ranged, specialization: WeaponSpecializations.pistol, damage: "7", range: WeaponRanges.short, magazine: 2, encumbrance: 1, cost: 500, availability: "Rare", traits: ["Close", "Flamer", "Inflict (Ablaze)", "Loud"]),
        WeaponTemplate(name: "Flamer", category: WeaponCategories.ranged, specialization: WeaponSpecializations.longGun, damage: "8", range: WeaponRanges.medium, magazine: 4, encumbrance: 2, cost: 1000, availability: "Scarce", traits: ["Flamer", "Inflict (Ablaze)", "Loud", "Two-handed"]),
        
        // Las Weapons
        WeaponTemplate(name: "Las Pistol", category: WeaponCategories.ranged, specialization: WeaponSpecializations.pistol, damage: "5", range: WeaponRanges.medium, magazine: 2, encumbrance: 0, cost: 400, availability: "Common", traits: ["Burst", "Close", "Loud", "Reliable"]),
        WeaponTemplate(name: "Lasgun", category: WeaponCategories.ranged, specialization: WeaponSpecializations.longGun, damage: "6", range: WeaponRanges.long, magazine: 4, encumbrance: 2, cost: 600, availability: "Common", traits: ["Burst", "Loud", "Reliable", "Two-handed"]),
        WeaponTemplate(name: "Las Carbine", category: WeaponCategories.ranged, specialization: WeaponSpecializations.longGun, damage: "5", range: WeaponRanges.medium, magazine: 3, encumbrance: 1, cost: 800, availability: "Common", traits: ["Burst", "Loud", "Reliable", "Two-handed"]),
        WeaponTemplate(name: "Long Las", category: WeaponCategories.ranged, specialization: WeaponSpecializations.longGun, damage: "6", range: WeaponRanges.extreme, magazine: 2, encumbrance: 2, cost: 1000, availability: "Scarce", traits: ["Burst", "Penetrating (1)", "Reliable", "Two-handed"]),
        WeaponTemplate(name: "Hot-Shot Laspistol", category: WeaponCategories.ranged, specialization: WeaponSpecializations.pistol, damage: "8", range: WeaponRanges.medium, magazine: 2, encumbrance: 2, cost: 900, availability: "Rare", traits: ["Burst", "Loud", "Penetrating (2)"]),
        WeaponTemplate(name: "Hot-Shot Lasgun", category: WeaponCategories.ranged, specialization: WeaponSpecializations.longGun, damage: "8", range: WeaponRanges.long, magazine: 3, encumbrance: 3, cost: 1000, availability: "Rare", traits: ["Burst", "Loud", "Penetrating (2)", "Two-handed"]),
        WeaponTemplate(name: "Lascannon", category: WeaponCategories.ranged, specialization: WeaponSpecializations.ordnance, damage: "18", range: WeaponRanges.extreme, magazine: 5, encumbrance: 4, cost: 8000, availability: "Rare", traits: ["Heavy (4)", "Loud", "Penetrating (10)", "Two-handed"]),
        
        // Launcher Weapons
        WeaponTemplate(name: "Grenade Launcher", category: WeaponCategories.ranged, specialization: WeaponSpecializations.ordnance, damage: "–", range: WeaponRanges.long, magazine: 6, encumbrance: 2, cost: 1000, availability: "Rare", traits: ["Loud", "Two-handed"]),
        WeaponTemplate(name: "Portable Missile Launcher", category: WeaponCategories.ranged, specialization: WeaponSpecializations.ordnance, damage: "–", range: WeaponRanges.extreme, magazine: 1, encumbrance: 3, cost: 2000, availability: "Rare", traits: ["Heavy (4)", "Loud", "Two-handed"]),
        
        // Melta Weapons
        WeaponTemplate(name: "Inferno Pistol", category: WeaponCategories.ranged, specialization: WeaponSpecializations.pistol, damage: "16", range: WeaponRanges.short, magazine: 3, encumbrance: 0, cost: 8000, availability: "Exotic", traits: ["Close", "Rend (5)"]),
        WeaponTemplate(name: "Meltagun", category: WeaponCategories.ranged, specialization: WeaponSpecializations.longGun, damage: "16", range: WeaponRanges.medium, magazine: 5, encumbrance: 1, cost: 9000, availability: "Rare", traits: ["Rend (5)", "Two-handed"]),
        
        // Plasma Weapons
        WeaponTemplate(name: "Plasma Pistol", category: WeaponCategories.ranged, specialization: WeaponSpecializations.pistol, damage: "10", range: WeaponRanges.medium, magazine: 6, encumbrance: 1, cost: 7000, availability: "Rare", traits: ["Close", "Loud", "Penetrating (6)", "Supercharge (4)", "Unstable"]),
        WeaponTemplate(name: "Plasma Gun", category: WeaponCategories.ranged, specialization: WeaponSpecializations.longGun, damage: "10", range: WeaponRanges.long, magazine: 12, encumbrance: 1, cost: 8000, availability: "Rare", traits: ["Loud", "Penetrating (6)", "Supercharge (4)", "Two-handed", "Unstable"]),
        
        // Solid Projectile Weapons
        WeaponTemplate(name: "Autopistol", category: WeaponCategories.ranged, specialization: WeaponSpecializations.pistol, damage: "5", range: WeaponRanges.medium, magazine: 3, encumbrance: 0, cost: 400, availability: "Common", traits: ["Close", "Loud", "Rapid Fire (3)"]),
        WeaponTemplate(name: "Autogun", category: WeaponCategories.ranged, specialization: WeaponSpecializations.longGun, damage: "6", range: WeaponRanges.long, magazine: 5, encumbrance: 1, cost: 600, availability: "Common", traits: ["Loud", "Rapid Fire (3)", "Two-handed"]),
        WeaponTemplate(name: "Hand Cannon", category: WeaponCategories.ranged, specialization: WeaponSpecializations.pistol, damage: "8", range: WeaponRanges.medium, magazine: 4, encumbrance: 2, cost: 570, availability: "Scarce", traits: ["Close", "Heavy (4)", "Loud", "Penetrating (2)"]),
        WeaponTemplate(name: "Heavy Stubber", category: WeaponCategories.ranged, specialization: WeaponSpecializations.ordnance, damage: "8", range: WeaponRanges.extreme, magazine: 8, encumbrance: 3, cost: 2000, availability: "Scarce", traits: ["Heavy (4)", "Loud", "Penetrating (3)", "Two-handed", "Rapid Fire (4)"]),
        WeaponTemplate(name: "Shotgun (Combat)", category: WeaponCategories.ranged, specialization: WeaponSpecializations.longGun, damage: "6", range: WeaponRanges.medium, magazine: 12, encumbrance: 1, cost: 600, availability: "Scarce", traits: ["Inflict (Prone)", "Loud", "Spread", "Two-handed"]),
        WeaponTemplate(name: "Shotgun (Pump Action)", category: WeaponCategories.ranged, specialization: WeaponSpecializations.longGun, damage: "6", range: WeaponRanges.medium, magazine: 8, encumbrance: 1, cost: 400, availability: "Common", traits: ["Inflict (Prone)", "Loud", "Spread", "Two-handed"]),
        WeaponTemplate(name: "Sniper Rifle", category: WeaponCategories.ranged, specialization: WeaponSpecializations.longGun, damage: "8", range: WeaponRanges.extreme, magazine: 6, encumbrance: 2, cost: 1000, availability: "Scarce", traits: ["Loud", "Two-handed"]),
        WeaponTemplate(name: "Stub Pistol", category: WeaponCategories.ranged, specialization: WeaponSpecializations.pistol, damage: "6", range: WeaponRanges.medium, magazine: 2, encumbrance: 0, cost: 250, availability: "Common", traits: ["Burst", "Close", "Loud"]),
        WeaponTemplate(name: "Stub Revolver", category: WeaponCategories.ranged, specialization: WeaponSpecializations.pistol, damage: "6", range: WeaponRanges.medium, magazine: 6, encumbrance: 0, cost: 200, availability: "Common", traits: ["Close", "Loud", "Reliable"]),
        
        // Specialised Ranged Weapons
        WeaponTemplate(name: "Needle Pistol", category: WeaponCategories.ranged, specialization: WeaponSpecializations.pistol, damage: "1", range: WeaponRanges.medium, magazine: 4, encumbrance: 1, cost: 1500, availability: "Exotic", traits: ["Close", "Inflict (Poisoned)", "Penetrating (6)", "Subtle"]),
        WeaponTemplate(name: "Needle Rifle", category: WeaponCategories.ranged, specialization: WeaponSpecializations.longGun, damage: "1", range: WeaponRanges.long, magazine: 6, encumbrance: 2, cost: 1700, availability: "Exotic", traits: ["Inflict (Poisoned)", "Penetrating (6)", "Subtle", "Two-handed"]),
        WeaponTemplate(name: "Web Pistol", category: WeaponCategories.ranged, specialization: WeaponSpecializations.pistol, damage: "–", range: WeaponRanges.short, magazine: 3, encumbrance: 1, cost: 1300, availability: "Rare", traits: ["Close", "Inflict (Restrained)"]),
        WeaponTemplate(name: "Webber", category: WeaponCategories.ranged, specialization: WeaponSpecializations.longGun, damage: "–", range: WeaponRanges.medium, magazine: 6, encumbrance: 1, cost: 1500, availability: "Rare", traits: ["Inflict (Restrained)", "Two-handed"])
    ]
    
    // MARK: - Melee Weapons
    static let meleeWeapons: [WeaponTemplate] = [
        // Chain Weapons
        WeaponTemplate(name: "Chainaxe", category: WeaponCategories.melee, specialization: WeaponSpecializations.oneHanded, damage: "3+StrB", encumbrance: 1, cost: 600, availability: "Rare", traits: ["Loud", "Rend (3)"]),
        WeaponTemplate(name: "Chainsword", category: WeaponCategories.melee, specialization: WeaponSpecializations.oneHanded, damage: "3+StrB", encumbrance: 1, cost: 500, availability: "Scarce", traits: ["Loud", "Rend (2)"]),
        WeaponTemplate(name: "Eviscerator", category: WeaponCategories.melee, specialization: WeaponSpecializations.twoHanded, damage: "5+StrB", encumbrance: 3, cost: 800, availability: "Rare", traits: ["Heavy (4)", "Loud", "Rend (4)", "Two-handed"]),
        
        // Force Weapons
        WeaponTemplate(name: "Force Staff", category: WeaponCategories.melee, specialization: WeaponSpecializations.twoHanded, damage: "1+StrB", encumbrance: 2, cost: 7000, availability: "Exotic", traits: ["Defensive", "Two-handed"]),
        WeaponTemplate(name: "Force Sword", category: WeaponCategories.melee, specialization: WeaponSpecializations.oneHanded, damage: "2+StrB", encumbrance: 1, cost: 8000, availability: "Exotic", traits: []),
        
        // Mundane Weapons
        WeaponTemplate(name: "Axe", category: WeaponCategories.melee, specialization: WeaponSpecializations.oneHanded, damage: "2+StrB", encumbrance: 1, cost: 80, availability: "Common", traits: []),
        WeaponTemplate(name: "Brass Knuckles", category: WeaponCategories.melee, specialization: WeaponSpecializations.brawling, damage: "0+StrB", encumbrance: 0, cost: 30, availability: "Common", traits: ["Subtle"]),
        WeaponTemplate(name: "Flail", category: WeaponCategories.melee, specialization: WeaponSpecializations.twoHanded, damage: "4+StrB", encumbrance: 2, cost: 200, availability: "Common", traits: ["Heavy (4)", "Two-handed"]),
        WeaponTemplate(name: "Great Weapon", category: WeaponCategories.melee, specialization: WeaponSpecializations.twoHanded, damage: "4+StrB", encumbrance: 2, cost: 300, availability: "Scarce", traits: ["Heavy (4)", "Two-handed"]),
        WeaponTemplate(name: "Hammer", category: WeaponCategories.melee, specialization: WeaponSpecializations.oneHanded, damage: "2+StrB", encumbrance: 1, cost: 25, availability: "Common", traits: []),
        WeaponTemplate(name: "Improvised (One-handed)", category: WeaponCategories.melee, specialization: WeaponSpecializations.oneHanded, damage: "1+StrB", encumbrance: 1, cost: 0, availability: "–", traits: ["Ineffective"]),
        WeaponTemplate(name: "Improvised (Two-handed)", category: WeaponCategories.melee, specialization: WeaponSpecializations.twoHanded, damage: "2+StrB", encumbrance: 3, cost: 0, availability: "–", traits: ["Ineffective", "Two-handed"]),
        WeaponTemplate(name: "Knife", category: WeaponCategories.melee, specialization: WeaponSpecializations.oneHanded, damage: "0+StrB", encumbrance: 0, cost: 50, availability: "Common", traits: ["Subtle", "Thrown (Short)"]),
        WeaponTemplate(name: "Staff", category: WeaponCategories.melee, specialization: WeaponSpecializations.twoHanded, damage: "1+StrB", encumbrance: 2, cost: 25, availability: "Common", traits: ["Defensive", "Two-handed"]),
        WeaponTemplate(name: "Sword", category: WeaponCategories.melee, specialization: WeaponSpecializations.oneHanded, damage: "2+StrB", encumbrance: 1, cost: 150, availability: "Common", traits: []),
        WeaponTemplate(name: "Unarmed", category: WeaponCategories.melee, specialization: WeaponSpecializations.brawling, damage: "0+StrB", encumbrance: 0, cost: 0, availability: "–", traits: ["Ineffective"]),
        WeaponTemplate(name: "Whip", category: WeaponCategories.melee, specialization: WeaponSpecializations.oneHanded, damage: "0+StrB", encumbrance: 1, cost: 60, availability: "Scarce", traits: ["Loud", "Reach"]),
        
        // Shock Weapons
        WeaponTemplate(name: "Electro-Flail", category: WeaponCategories.melee, specialization: WeaponSpecializations.oneHanded, damage: "0+StrB", encumbrance: 1, cost: 500, availability: "Scarce", traits: ["Loud", "Reach", "Inflict (Stunned)"]),
        WeaponTemplate(name: "Shock Maul", category: WeaponCategories.melee, specialization: WeaponSpecializations.oneHanded, damage: "2+StrB", encumbrance: 1, cost: 250, availability: "Scarce", traits: ["Loud", "Inflict (Stunned)"]),
        
        // Power Weapons
        WeaponTemplate(name: "Power Axe", category: WeaponCategories.melee, specialization: WeaponSpecializations.twoHanded, damage: "6+StrB", encumbrance: 2, cost: 3400, availability: "Rare", traits: ["Heavy (4)", "Penetrating (6)", "Two-handed"]),
        WeaponTemplate(name: "Power Fist", category: WeaponCategories.melee, specialization: WeaponSpecializations.brawling, damage: "6+StrB", encumbrance: 2, cost: 4000, availability: "Rare", traits: ["Heavy (4)", "Penetrating (6)"]),
        WeaponTemplate(name: "Power Knife", category: WeaponCategories.melee, specialization: WeaponSpecializations.oneHanded, damage: "2+StrB", encumbrance: 1, cost: 2000, availability: "Rare", traits: ["Penetrating (2)", "Subtle", "Thrown (Short)"]),
        WeaponTemplate(name: "Power Maul", category: WeaponCategories.melee, specialization: WeaponSpecializations.oneHanded, damage: "5+StrB", encumbrance: 1, cost: 3000, availability: "Rare", traits: ["Penetrating (2)"]),
        WeaponTemplate(name: "Power Sword", category: WeaponCategories.melee, specialization: WeaponSpecializations.oneHanded, damage: "4+StrB", encumbrance: 1, cost: 3000, availability: "Rare", traits: ["Penetrating (4)"])
    ]
    
    // MARK: - Grenades and Explosives
    static let grenadesAndExplosives: [WeaponTemplate] = [
        // Note: The issue description repeated melee weapons in this section,
        // so I'll add common grenades and explosives from Warhammer 40K lore
        WeaponTemplate(name: "Frag Grenade", category: WeaponCategories.grenades, specialization: WeaponSpecializations.none, damage: "6", range: WeaponRanges.short, magazine: 1, encumbrance: 0, cost: 25, availability: "Common", traits: ["Blast (3)", "Thrown (Short)"]),
        WeaponTemplate(name: "Krak Grenade", category: WeaponCategories.grenades, specialization: WeaponSpecializations.none, damage: "10", range: WeaponRanges.short, magazine: 1, encumbrance: 0, cost: 50, availability: "Scarce", traits: ["Penetrating (6)", "Thrown (Short)"]),
        WeaponTemplate(name: "Smoke Grenade", category: WeaponCategories.grenades, specialization: WeaponSpecializations.none, damage: "–", range: WeaponRanges.short, magazine: 1, encumbrance: 0, cost: 15, availability: "Common", traits: ["Blast (5)", "Smoke", "Thrown (Short)"]),
        WeaponTemplate(name: "Stun Grenade", category: WeaponCategories.grenades, specialization: WeaponSpecializations.none, damage: "2", range: WeaponRanges.short, magazine: 1, encumbrance: 0, cost: 30, availability: "Common", traits: ["Blast (3)", "Inflict (Stunned)", "Thrown (Short)"])
    ]
    
    static let allWeapons: [WeaponTemplate] = rangedWeapons + meleeWeapons + grenadesAndExplosives
    
    static func getTemplate(for name: String) -> WeaponTemplate? {
        return allWeapons.first { $0.name.lowercased() == name.lowercased() }
    }
    
    static func getWeaponsByCategory(_ category: String) -> [WeaponTemplate] {
        return allWeapons.filter { $0.category == category }
    }
}

// MARK: - Weapon Modification System
struct WeaponModification: Codable {
    var name: String
    var cost: Int
    var availability: String
    var usedWith: String
    var description: String
    
    init(name: String, cost: Int = 0, availability: String = "Common", usedWith: String = "", description: String = "") {
        self.name = name
        self.cost = cost
        self.availability = availability
        self.usedWith = usedWith
        self.description = description
    }
}

struct WeaponModificationDefinitions {
    // Combat Attachments
    static let exterminatorCartridge = WeaponModification(
        name: "Exterminator Cartridge",
        cost: 100,
        availability: "Common",
        usedWith: "Any Melee or Ranged weapon with the Two-Handed trait",
        description: "An Exterminator Cartridge is a stripped-down Flamer with enough fuel for a single use. They are popular among Imperial fanatics and zealots, who attach them to roaring Chainswords to douse their foes in cleansing fire as they charge in a blazing embodiment of the Emperor's fury. It can be attached to any melee or ranged weapon with the Two-handed Trait and fired as a Ranged Attack. Once fired, the cartridge is expended and takes 5 minutes to replace or reload."
    )
    
    static let meleeAttachment = WeaponModification(
        name: "Melee Attachment",
        cost: 50,
        availability: "Scarce",
        usedWith: "Any Ranged Weapon with the Two-Handed trait",
        description: "Most commonly known as bayonets, melee attachments affix a long blade to the end of a ranged weapon such as a Lasgun, Autogun, or Flamer. They often mean the difference between life and death in close combat. It functions as a Mundane Sword, can be affixed to or removed from a two-handed Ranged Weapon as an Action, and counts as a melee weapon for defending yourself. When unattached, it counts as an Improvised (One-handed) weapon."
    )
    
    static let monoEdge = WeaponModification(
        name: "Mono-edge",
        cost: 250,
        availability: "Rare",
        usedWith: "Mundane melee weapons",
        description: "Popular among assassins and other fighters, Mono-edges are molecular-thin superfine blades that never dull. Applied to a Mundane bladed melee weapon, it grants the Penetrating (2) Trait, or increases an existing Penetrating rating by 2."
    )
    
    // Sights
    static let photoSight = WeaponModification(
        name: "Photo Sight",
        cost: 200,
        availability: "Rare",
        usedWith: "Any Ranged Weapon without the Blast or Flamer traits",
        description: "A Photo Sight uses spectral sensors to analyse wavelengths outside of Human perception, allowing the user to see in darkness. It can be attached to any ranged weapon and removes Disadvantage when firing into a Dark or Poorly Lit Zone."
    )
    
    static let laserSight = WeaponModification(
        name: "Laser Sight",
        cost: 50,
        availability: "Scarce",
        usedWith: "Any Ranged Weapon without the Blast or Flamer traits",
        description: "A low-power laser attachment used to pick out a target for more accurate shots. Adds +1 SL to Ranged Attacks made with the weapon, but targets gain Advantage on Awareness Tests to spot the user. If the red dot is seen, the target may attempt an Opposed Dodge (Reflexes) Test."
    )
    
    static let telescopicSight = WeaponModification(
        name: "Telescopic Sight",
        cost: 50,
        availability: "Common",
        usedWith: "Any Ranged Weapon without the Blast or Flamer traits",
        description: "Also called an Omniscope, this bulky arrangement of lenses increases a weapon's Range by one step, but removes the Close trait if present. It can also function as Magnoculars."
    )
    
    // Support Attachments
    static let backpackAmmoSupply = WeaponModification(
        name: "Backpack Ammo Supply",
        cost: 0, // Has the same Cost and Availability as the linked weapon
        availability: "–",
        usedWith: "Any Ranged Weapon",
        description: "Quadruples a linked weapon's Magazine size but adds +2 Encumbrance. Reloading takes 5 minutes. If destroyed in an explosion (Critical Hit with a roll of 7+), it detonates, doubling the weapon's Damage to the user's Torso. Has the same Cost and Availability as the linked weapon."
    )
    
    static let bipod = WeaponModification(
        name: "Bipod",
        cost: 30,
        availability: "–",
        usedWith: "Any Ranged Weapon",
        description: "Allows the user to brace Heavy weapons anywhere without cover or terrain support."
    )
    
    static let fireSelector = WeaponModification(
        name: "Fire Selector",
        cost: 140,
        availability: "Rare",
        usedWith: "Bolt, Launcher, Low-Tech, and Solid Projectile ranged weapons",
        description: "Complex magazines that can load up to three types of ammunition, allowing the user to switch between them as a Free Action. A weapon with a Fire Selector loses the Reliable Trait if it has it."
    )
    
    static let silencer = WeaponModification(
        name: "Silencer",
        cost: 400,
        availability: "Common",
        usedWith: "Solid Projectile ranged weapons",
        description: "Uses sonic baffles and other devices to reduce the noise of a weapon. While attached, a Silencer removes the weapon's Loud Trait."
    )
    
    static let allModifications: [WeaponModification] = [
        exterminatorCartridge, meleeAttachment, monoEdge, photoSight, laserSight,
        telescopicSight, backpackAmmoSupply, bipod, fireSelector, silencer
    ]
    
    static func getModification(for name: String) -> WeaponModification? {
        return allModifications.first { $0.name.lowercased() == name.lowercased() }
    }
}