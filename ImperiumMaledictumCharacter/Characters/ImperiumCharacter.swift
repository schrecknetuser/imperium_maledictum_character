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
    var selectedFactionTalentChoice: String = "" // Index or name of selected faction talent choice
    
    // Additional character description fields
    var shortTermGoal: String = ""
    var longTermGoal: String = ""
    var characterDescription: String = ""
    
    // Critical wounds and injuries
    var criticalWounds: Int = 0
    var headInjuries: String = "" // JSON array of head injuries
    var armInjuries: String = "" // JSON array of arm injuries  
    var bodyInjuries: String = "" // JSON array of body injuries
    var legInjuries: String = "" // JSON array of leg injuries
    
    // Conditions
    var conditionsData: String = "" // JSON array of active conditions
    
    // Core characteristics - using new data model approach 
    var characteristicsData: String = "" // JSON data for characteristics
    var skillsAdvancesData: String = "" // JSON data for skill advances
    var factionSkillAdvancesData: String = "" // JSON data for faction-specific skill advances
    var specializationAdvancesData: String = "" // JSON data for specialization advances
    var talentNamesData: String = "" // JSON array of talent names
    var equipmentNamesData: String = "" // JSON array of equipment names - DEPRECATED
    var weaponNamesData: String = "" // JSON array of weapon names - DEPRECATED
    var equipmentListData: String = "" // JSON array of Equipment objects
    var weaponListData: String = "" // JSON array of Weapon objects
    var reputationData: String = "" // JSON data for reputation
    
    // Bonus tracking to prevent double application
    var appliedOriginBonuses: String = "" // JSON string tracking which origin bonuses have been applied
    var appliedFactionBonuses: String = "" // JSON string tracking which faction bonuses have been applied
    
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
    var spentFate: Int = 0
    var solars: Int = 0
    
    // Experience tracking
    var totalExperience: Int = 0
    var spentExperience: Int = 0
    
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
        shortTermGoal = ""
        longTermGoal = ""
        characterDescription = ""
        criticalWounds = 0
        headInjuries = ""
        armInjuries = ""
        bodyInjuries = ""
        legInjuries = ""
        conditionsData = ""
        
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
        
        // Reset derived stats
        wounds = 0
        maxWounds = calculateMaxWounds()
        corruption = 0
        stress = 0
        fate = 3
        spentFate = 0
        solars = 0
        totalExperience = 0
        spentExperience = 0
        
        // Reset data
        skillsData = ""
        talentsData = ""
        equipmentData = ""
        psychicPowersData = ""
        
        // Initialize new data structures
        characteristicsData = ""
        skillsAdvancesData = ""
        factionSkillAdvancesData = ""
        specializationAdvancesData = ""
        talentNamesData = ""
        equipmentNamesData = ""
        weaponNamesData = ""
        equipmentListData = ""
        weaponListData = ""
        reputationData = ""
        appliedOriginBonuses = ""
        appliedFactionBonuses = ""
        
        creationProgress = 0
        isArchived = false
        lastModified = Date()
    }
    
    func completeCreation() {
        creationProgress = CreationStages.totalStages
        maxWounds = calculateMaxWounds()
        lastModified = Date()
    }
    
    func calculateMaxWounds() -> Int {
        // New formula: (current_strength - current_strength%10)/10 + (current_willpower-current_willpower%10)/10 + 2*(current_toughness - current_toughness%10)/10
        let strengthComponent = (strength - strength % 10) / 10
        let willpowerComponent = (willpower - willpower % 10) / 10
        let toughnessComponent = 2 * ((toughness - toughness % 10) / 10)
        return strengthComponent + willpowerComponent + toughnessComponent
    }
    
    func calculateCorruptionThreshold() -> Int {
        // Corruption threshold: (current_willpower-current_willpower%10)/10 + (current_toughness - current_toughness%10)/10
        let willpowerComponent = (willpower - willpower % 10) / 10
        let toughnessComponent = (toughness - toughness % 10) / 10
        return willpowerComponent + toughnessComponent
    }
    
    func calculateCriticalWoundsThreshold() -> Int {
        // Critical wounds threshold: (toughness - toughness%10)/10
        return (toughness - toughness % 10) / 10
    }
    
    var availableExperience: Int {
        return totalExperience - spentExperience
    }
    
    // Method to count active critical wounds (those that don't have "None" or "None." as treatment)
    func countActiveCriticalWounds() -> Int {
        let allInjuries = headInjuriesList + armInjuriesList + bodyInjuriesList + legInjuriesList
        return allInjuries.filter { injury in
            let treatment = injury.treatment.trimmingCharacters(in: .whitespacesAndNewlines)
            return treatment.lowercased() != "none" && treatment.lowercased() != "none."
        }.count
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
    
    var factionSkillAdvances: [String: Int] {
        get {
            guard let data = factionSkillAdvancesData.data(using: .utf8),
                  let decoded = try? JSONDecoder().decode([String: Int].self, from: data) else {
                return [:]
            }
            return decoded
        }
        set {
            if let encoded = try? JSONEncoder().encode(newValue) {
                factionSkillAdvancesData = String(data: encoded, encoding: .utf8) ?? ""
            }
            lastModified = Date()
        }
    }
    
    var specializationAdvances: [String: Int] {
        get {
            guard let data = specializationAdvancesData.data(using: .utf8),
                  let decoded = try? JSONDecoder().decode([String: Int].self, from: data) else {
                return [:]
            }
            return decoded
        }
        set {
            if let encoded = try? JSONEncoder().encode(newValue) {
                specializationAdvancesData = String(data: encoded, encoding: .utf8) ?? ""
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
    
    var equipmentNames: [String] {
        get {
            guard let data = equipmentNamesData.data(using: .utf8),
                  let decoded = try? JSONDecoder().decode([String].self, from: data) else {
                return []
            }
            return decoded
        }
        set {
            if let encoded = try? JSONEncoder().encode(newValue) {
                equipmentNamesData = String(data: encoded, encoding: .utf8) ?? ""
            }
            lastModified = Date()
        }
    }
    
    var weaponNames: [String] {
        get {
            guard let data = weaponNamesData.data(using: .utf8),
                  let decoded = try? JSONDecoder().decode([String].self, from: data) else {
                return []
            }
            return decoded
        }
        set {
            if let encoded = try? JSONEncoder().encode(newValue) {
                weaponNamesData = String(data: encoded, encoding: .utf8) ?? ""
            }
            lastModified = Date()
        }
    }
    
    var equipmentList: [Equipment] {
        get {
            guard let data = equipmentListData.data(using: .utf8),
                  let decoded = try? JSONDecoder().decode([Equipment].self, from: data) else {
                return []
            }
            return decoded
        }
        set {
            if let encoded = try? JSONEncoder().encode(newValue) {
                equipmentListData = String(data: encoded, encoding: .utf8) ?? ""
            }
            lastModified = Date()
        }
    }
    
    var weaponList: [Weapon] {
        get {
            guard let data = weaponListData.data(using: .utf8),
                  let decoded = try? JSONDecoder().decode([Weapon].self, from: data) else {
                return []
            }
            return decoded
        }
        set {
            if let encoded = try? JSONEncoder().encode(newValue) {
                weaponListData = String(data: encoded, encoding: .utf8) ?? ""
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
    
    var appliedOriginBonusesTracker: [String: Bool] {
        get {
            guard let data = appliedOriginBonuses.data(using: .utf8),
                  let decoded = try? JSONDecoder().decode([String: Bool].self, from: data) else {
                return [:]
            }
            return decoded
        }
        set {
            if let encoded = try? JSONEncoder().encode(newValue) {
                appliedOriginBonuses = String(data: encoded, encoding: .utf8) ?? ""
            }
            lastModified = Date()
        }
    }
    
    var appliedFactionBonusesTracker: [String: Bool] {
        get {
            guard let data = appliedFactionBonuses.data(using: .utf8),
                  let decoded = try? JSONDecoder().decode([String: Bool].self, from: data) else {
                return [:]
            }
            return decoded
        }
        set {
            if let encoded = try? JSONEncoder().encode(newValue) {
                appliedFactionBonuses = String(data: encoded, encoding: .utf8) ?? ""
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
    
    // MARK: - Injury Management
    
    var headInjuriesList: [CriticalWound] {
        get {
            guard let data = headInjuries.data(using: .utf8),
                  let decoded = try? JSONDecoder().decode([CriticalWound].self, from: data) else {
                return []
            }
            return decoded
        }
        set {
            if let encoded = try? JSONEncoder().encode(newValue) {
                headInjuries = String(data: encoded, encoding: .utf8) ?? ""
            }
            lastModified = Date()
        }
    }
    
    var armInjuriesList: [CriticalWound] {
        get {
            guard let data = armInjuries.data(using: .utf8),
                  let decoded = try? JSONDecoder().decode([CriticalWound].self, from: data) else {
                return []
            }
            return decoded
        }
        set {
            if let encoded = try? JSONEncoder().encode(newValue) {
                armInjuries = String(data: encoded, encoding: .utf8) ?? ""
            }
            lastModified = Date()
        }
    }
    
    var bodyInjuriesList: [CriticalWound] {
        get {
            guard let data = bodyInjuries.data(using: .utf8),
                  let decoded = try? JSONDecoder().decode([CriticalWound].self, from: data) else {
                return []
            }
            return decoded
        }
        set {
            if let encoded = try? JSONEncoder().encode(newValue) {
                bodyInjuries = String(data: encoded, encoding: .utf8) ?? ""
            }
            lastModified = Date()
        }
    }
    
    var legInjuriesList: [CriticalWound] {
        get {
            guard let data = legInjuries.data(using: .utf8),
                  let decoded = try? JSONDecoder().decode([CriticalWound].self, from: data) else {
                return []
            }
            return decoded
        }
        set {
            if let encoded = try? JSONEncoder().encode(newValue) {
                legInjuries = String(data: encoded, encoding: .utf8) ?? ""
            }
            lastModified = Date()
        }
    }
    
    // MARK: - Condition Management
    
    var conditionsList: [Condition] {
        get {
            guard let data = conditionsData.data(using: .utf8),
                  let decoded = try? JSONDecoder().decode([Condition].self, from: data) else {
                return []
            }
            return decoded
        }
        set {
            if let encoded = try? JSONEncoder().encode(newValue) {
                conditionsData = String(data: encoded, encoding: .utf8) ?? ""
            }
            lastModified = Date()
        }
    }
    
    // MARK: - Migration Methods
    
    /// Migrates equipment and weapons from string arrays to proper Equipment/Weapon objects
    func migrateEquipmentAndWeapons() {
        // Only migrate if we have old data and no new data
        if !equipmentNames.isEmpty && equipmentList.isEmpty {
            var newEquipmentList: [Equipment] = []
            
            for equipmentName in equipmentNames {
                // Parse basic equipment from name
                let equipment = Equipment(name: equipmentName)
                newEquipmentList.append(equipment)
            }
            
            equipmentList = newEquipmentList
            // Keep old data for backward compatibility, but mark it as migrated by clearing it
            // equipmentNames = [] // Uncomment this line if you want to clear old data after migration
        }
        
        if !weaponNames.isEmpty && weaponList.isEmpty {
            var newWeaponList: [Weapon] = []
            
            for weaponName in weaponNames {
                // Parse basic weapon from name
                let weapon = Weapon(name: weaponName)
                newWeaponList.append(weapon)
            }
            
            weaponList = newWeaponList
            // Keep old data for backward compatibility, but mark it as migrated by clearing it
            // weaponNames = [] // Uncomment this line if you want to clear old data after migration
        }
        
        lastModified = Date()
    }
}