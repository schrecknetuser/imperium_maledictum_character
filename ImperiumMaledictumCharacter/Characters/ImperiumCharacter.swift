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
    
    // Core characteristics - using new data model approach 
    var characteristicsData: String = "" // JSON data for characteristics
    var skillsAdvancesData: String = "" // JSON data for skill advances
    var talentNamesData: String = "" // JSON array of talent names
    var equipmentNamesData: String = "" // JSON array of equipment names  
    var weaponNamesData: String = "" // JSON array of weapon names
    var reputationData: String = "" // JSON data for reputation
    
    // Legacy characteristic properties for backward compatibility
    var weaponSkill: Int = 25
    var ballisticSkill: Int = 25  
    var strength: Int = 25
    var toughness: Int = 25
    var agility: Int = 25
    var intelligence: Int = 25
    var willpower: Int = 25
    var fellowship: Int = 25
    var influence: Int = 25
    var perception: Int = 25 // Added Perception characteristic
    
    // Derived stats
    var wounds: Int = 0
    var maxWounds: Int = 0
    var corruption: Int = 0
    var stress: Int = 0
    var fate: Int = 3
    var solars: Int = 0
    
    // Skills (stored as JSON string) - DEPRECATED, use skillsAdvancesData 
    var skillsData: String = ""
    var talentsData: String = "" // DEPRECATED, use talentNamesData
    var equipmentData: String = "" // DEPRECATED, use equipmentNamesData
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
        
        // Reset characteristics to base values (new system uses 20 as base)
        weaponSkill = 20
        ballisticSkill = 20
        strength = 20
        toughness = 20
        agility = 20
        intelligence = 20
        willpower = 20
        fellowship = 20
        influence = 20 // Keep influence as legacy system
        perception = 20
        perception = 20
        
        // Reset derived stats
        wounds = 0
        maxWounds = calculateMaxWounds()
        corruption = 0
        stress = 0
        fate = 3
        solars = 0
        
        // Reset data
        skillsData = ""
        talentsData = ""
        equipmentData = ""
        psychicPowersData = ""
        
        // Initialize new data structures
        characteristicsData = ""
        skillsAdvancesData = ""
        talentNamesData = ""
        equipmentNamesData = ""
        weaponNamesData = ""
        reputationData = ""
        
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
    
    // MARK: - New Data Model Convenience Methods
    
    var characteristics: [String: Characteristic] {
        get {
            guard let data = characteristicsData.data(using: .utf8),
                  let decoded = try? JSONDecoder().decode([String: Characteristic].self, from: data) else {
                // Initialize with default characteristics if empty
                return createDefaultCharacteristics()
            }
            return decoded
        }
        set {
            if let encoded = try? JSONEncoder().encode(newValue) {
                characteristicsData = String(data: encoded, encoding: .utf8) ?? ""
            }
            lastModified = Date()
        }
    }
    
    var skillAdvances: [String: Int] {
        get {
            guard let data = skillsAdvancesData.data(using: .utf8),
                  let decoded = try? JSONDecoder().decode([String: Int].self, from: data) else {
                return [:]
            }
            return decoded
        }
        set {
            if let encoded = try? JSONEncoder().encode(newValue) {
                skillsAdvancesData = String(data: encoded, encoding: .utf8) ?? ""
            }
            lastModified = Date()
        }
    }
    
    var talentNames: [String] {
        get {
            guard let data = talentNamesData.data(using: .utf8),
                  let decoded = try? JSONDecoder().decode([String].self, from: data) else {
                return []
            }
            return decoded
        }
        set {
            if let encoded = try? JSONEncoder().encode(newValue) {
                talentNamesData = String(data: encoded, encoding: .utf8) ?? ""
            }
            lastModified = Date()
        }
    }
    
    var reputations: [Reputation] {
        get {
            guard let data = reputationData.data(using: .utf8),
                  let decoded = try? JSONDecoder().decode([Reputation].self, from: data) else {
                return []
            }
            return decoded
        }
        set {
            if let encoded = try? JSONEncoder().encode(newValue) {
                reputationData = String(data: encoded, encoding: .utf8) ?? ""
            }
            lastModified = Date()
        }
    }
    
    private func createDefaultCharacteristics() -> [String: Characteristic] {
        var defaults: [String: Characteristic] = [:]
        for name in CharacteristicNames.allCharacteristics {
            defaults[name] = Characteristic(name: name, initialValue: 20, advances: 0)
        }
        return defaults
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
            return !name.isEmpty
        case 1: // Characteristics
            return true // Can proceed with default allocation
        case 2: // Origin
            return !homeworld.isEmpty
        case 3: // Faction
            return !faction.isEmpty
        case 4: // Role
            return !role.isEmpty
        case 5: // Complete
            return true
        default:
            return false
        }
    }
}