//
//  CharacterBase.swift
//  ImperiumMaledictumCharacter
//
//  Created by User on 11.01.2025.
//

import Foundation
import SwiftData

// MARK: - Base Character Protocol
protocol BaseCharacter: AnyObject, Identifiable {
    var id: UUID { get set }
    var name: String { get set }
    var player: String { get set }
    var campaign: String { get set }
    var isArchived: Bool { get set }
    var creationProgress: Int { get set }
    var isCreationComplete: Bool { get }
    var characterType: CharacterType { get }
    
    // Creation stages tracking
    var faction: String { get set }
    var role: String { get set }
    var homeworld: String { get set }
    
    // Core characteristics
    var weaponSkill: Int { get set }
    var ballisticSkill: Int { get set }
    var strength: Int { get set }
    var toughness: Int { get set }
    var agility: Int { get set }
    var intelligence: Int { get set }
    var willpower: Int { get set }
    var fellowship: Int { get set }
    var influence: Int { get set }
    var perception: Int { get set }
    
    // Status tracking
    var wounds: Int { get set }
    var maxWounds: Int { get set }
    var corruption: Int { get set }
    
    func resetToDefaults()
    func completeCreation()
}

// MARK: - Character Type Enum
enum CharacterType: String, CaseIterable, Codable {
    case acolyte = "Acolyte"
    case guardsman = "Guardsman"
    case noble = "Noble"
    case psyker = "Psyker"
    case scum = "Scum"
    case techPriest = "Tech-Priest"
    case arbitrator = "Arbitrator"
    case sister = "Sister of Battle"
    case spaceMarine = "Space Marine"
    
    var symbol: String {
        switch self {
        case .acolyte:
            return "🔮"
        case .guardsman:
            return "⚔️"
        case .noble:
            return "👑"
        case .psyker:
            return "🧠"
        case .scum:
            return "🗡️"
        case .techPriest:
            return "⚙️"
        case .arbitrator:
            return "⚖️"
        case .sister:
            return "✝️"
        case .spaceMarine:
            return "🛡️"
        }
    }
}

// MARK: - Helper Structs
struct AnyCharacter: Identifiable {
    let id: UUID
    let character: any BaseCharacter
    
    init(character: any BaseCharacter) {
        self.id = character.id
        self.character = character
    }
}

struct IdentifiableCharacter: Identifiable {
    let id = UUID()
    let character: any BaseCharacter
}

// MARK: - Creation Constants
struct CreationStages {
    static let totalStages = 6
    
    static let stageNames = [
        "Basic Info",
        "Characteristics",
        "Origin", 
        "Faction",
        "Role",
        "Complete"
    ]
    
    static func stageName(for index: Int) -> String {
        guard index >= 0 && index < stageNames.count else {
            return "Unknown"
        }
        return stageNames[index]
    }
}

// MARK: - Faction Constants
struct ImperiumFactions {
    static let all = [
        "Adeptus Administratum",
        "Adeptus Arbites", 
        "Adeptus Astra Telepathica",
        "Adeptus Mechanicus",
        "Astra Militarum",
        "Ecclesiarchy",
        "Imperial Navy",
        "Inquisition",
        "Rogue Trader Dynasty",
        "Adeptus Astartes"
    ]
}

// MARK: - Role Constants  
struct ImperiumRoles {
    static let rolesByFaction: [String: [String]] = [
        "Adeptus Administratum": ["Scribe", "Clerk", "Adept", "Bureaucrat"],
        "Adeptus Arbites": ["Arbitrator", "Chastener", "Proctor", "Judge"],
        "Adeptus Astra Telepathica": ["Astropath", "Sanctioned Psyker", "Void Dreamer"],
        "Adeptus Mechanicus": ["Tech-Priest", "Enginseer", "Lexmechanic", "Artisan"],
        "Astra Militarum": ["Guardsman", "Sergeant", "Commissar", "Officer"],
        "Ecclesiarchy": ["Priest", "Confessor", "Sister of Battle", "Missionary"],
        "Imperial Navy": ["Rating", "Petty Officer", "Officer", "Pilot"],
        "Inquisition": ["Acolyte", "Interrogator", "Inquisitor", "Death Cult Assassin"],
        "Rogue Trader Dynasty": ["Rogue Trader", "Navigator", "Seneschal", "Void-Master"],
        "Adeptus Astartes": ["Scout", "Battle-Brother", "Sergeant", "Captain"]
    ]
    
    static func roles(for faction: String) -> [String] {
        return rolesByFaction[faction] ?? []
    }
}

// MARK: - Display Data Structures
struct CharacteristicRowData {
    let abbreviation: String
    let name: String
    let baseValue: Int
    let advances: Int
    let totalValue: Int
}

struct SkillRowData {
    let name: String
    let characteristicAbbreviation: String
    let advances: Int
    let totalValue: Int
}

struct SpecializationRowData: Identifiable {
    let id: String
    let name: String
    let skillName: String
    let advances: Int
    let totalValue: Int
    
    init(name: String, skillName: String, advances: Int, totalValue: Int) {
        self.name = name
        self.skillName = skillName
        self.advances = advances
        self.totalValue = totalValue
        self.id = "\(name)_\(skillName)"
    }
}