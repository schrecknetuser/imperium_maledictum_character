//
//  ImperiumCharacter.swift
//  ImperiumMaledictumCharacter
//
//  Created by User on 11.01.2025.
//

import Foundation
import SwiftData

@Model
class ImperiumCharacter: BaseCharacter {
    var id: UUID = UUID()
    var name: String = ""
    var player: String = ""
    var campaign: String = ""
    var isArchived: Bool = false
    var creationProgress: Int = 0
    
    // Basic character info
    var faction: String = ""
    var role: String = ""
    var homeworld: String = ""
    var background: String = ""
    var goal: String = ""
    var nemesis: String = ""
    
    // Core characteristics (base values)
    var weaponSkill: Int = 25
    var ballisticSkill: Int = 25
    var strength: Int = 25
    var toughness: Int = 25
    var agility: Int = 25
    var intelligence: Int = 25
    var willpower: Int = 25
    var fellowship: Int = 25
    var influence: Int = 25
    
    // Derived stats
    var wounds: Int = 0
    var maxWounds: Int = 0
    var corruption: Int = 0
    var stress: Int = 0
    var fate: Int = 3
    var thrones: Int = 0
    
    // Skills (stored as JSON string)
    var skillsData: String = ""
    var talentsData: String = ""
    var equipmentData: String = ""
    var psychicPowersData: String = ""
    
    // Creation tracking
    var dateCreated: Date = Date()
    var lastModified: Date = Date()
    
    var characterType: CharacterType {
        return .acolyte // Default, could be determined by role
    }
    
    var isCreationComplete: Bool {
        return creationProgress >= CreationStages.totalStages
    }
    
    init() {
        super.init()
        resetToDefaults()
    }
    
    func resetToDefaults() {
        name = ""
        player = ""
        campaign = ""
        faction = ""
        role = ""
        homeworld = ""
        background = ""
        goal = ""
        nemesis = ""
        
        // Reset characteristics to base values
        weaponSkill = 25
        ballisticSkill = 25
        strength = 25
        toughness = 25
        agility = 25
        intelligence = 25
        willpower = 25
        fellowship = 25
        influence = 25
        
        // Reset derived stats
        wounds = 0
        maxWounds = calculateMaxWounds()
        corruption = 0
        stress = 0
        fate = 3
        thrones = 0
        
        // Reset data
        skillsData = ""
        talentsData = ""
        equipmentData = ""
        psychicPowersData = ""
        
        creationProgress = 0
        isArchived = false
        lastModified = Date()
    }
    
    func completeCreation() {
        creationProgress = CreationStages.totalStages
        maxWounds = calculateMaxWounds()
        lastModified = Date()
    }
    
    private func calculateMaxWounds() -> Int {
        // Basic wounds calculation based on Toughness and Willpower
        return (toughness + willpower) / 10 + 10
    }
    
    // Convenience methods for skills, talents, etc.
    var skills: [String: Int] {
        get {
            guard let data = skillsData.data(using: .utf8),
                  let decoded = try? JSONDecoder().decode([String: Int].self, from: data) else {
                return [:]
            }
            return decoded
        }
        set {
            if let encoded = try? JSONEncoder().encode(newValue) {
                skillsData = String(data: encoded, encoding: .utf8) ?? ""
            }
            lastModified = Date()
        }
    }
    
    var talents: [String] {
        get {
            guard let data = talentsData.data(using: .utf8),
                  let decoded = try? JSONDecoder().decode([String].self, from: data) else {
                return []
            }
            return decoded
        }
        set {
            if let encoded = try? JSONEncoder().encode(newValue) {
                talentsData = String(data: encoded, encoding: .utf8) ?? ""
            }
            lastModified = Date()
        }
    }
    
    var equipment: [String] {
        get {
            guard let data = equipmentData.data(using: .utf8),
                  let decoded = try? JSONDecoder().decode([String].self, from: data) else {
                return []
            }
            return decoded
        }
        set {
            if let encoded = try? JSONEncoder().encode(newValue) {
                equipmentData = String(data: encoded, encoding: .utf8) ?? ""
            }
            lastModified = Date()
        }
    }
    
    var psychicPowers: [String] {
        get {
            guard let data = psychicPowersData.data(using: .utf8),
                  let decoded = try? JSONDecoder().decode([String].self, from: data) else {
                return []
            }
            return decoded
        }
        set {
            if let encoded = try? JSONEncoder().encode(newValue) {
                psychicPowersData = String(data: encoded, encoding: .utf8) ?? ""
            }
            lastModified = Date()
        }
    }
    
    // Helper methods
    func getCurrentStage() -> String {
        return CreationStages.stageName(for: creationProgress)
    }
    
    func advanceCreationStage() {
        if creationProgress < CreationStages.totalStages {
            creationProgress += 1
            lastModified = Date()
        }
    }
    
    func canAdvanceStage() -> Bool {
        switch creationProgress {
        case 0: // Basic Info
            return !name.isEmpty && !player.isEmpty
        case 1: // Faction & Role
            return !faction.isEmpty && !role.isEmpty
        case 2: // Homeworld
            return !homeworld.isEmpty
        case 3: // Characteristics
            return true // Characteristics have defaults
        case 4: // Skills & Talents
            return true // Can skip or add later
        case 5: // Equipment
            return true // Can skip or add later
        default:
            return false
        }
    }
}