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
    var selectedFactionTalentChoice: String = "" // Index or name of selected faction talent choice
    
    // Additional character description fields
    var shortTermGoal: String = ""
    var longTermGoal: String = ""
    var characterDescription: String = ""
    var notes: String = ""
    
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
    var specializationAdvancesData: String = "" // JSON data for specialization advances - DEPRECATED 
    var skillSpecializationsData: String = "" // JSON data for skill-based specialization storage: [String: [String: Int]]
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
    
    // Change history tracking
    var currentSession: Int = 1
    var changeLog: [ChangeLogEntry] = []
    
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
        shortTermGoal = ""
        longTermGoal = ""
        characterDescription = ""
        notes = ""
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
        specializationAdvancesData = "" // Keep for legacy compatibility
        skillSpecializationsData = ""
        talentNamesData = ""
        equipmentNamesData = ""
        weaponNamesData = ""
        equipmentListData = ""
        weaponListData = ""
        reputationData = ""
        appliedOriginBonuses = ""
        appliedFactionBonuses = ""
        
        // Initialize change history
        currentSession = 1
        changeLog = [ChangeLogEntry(summary: "Character created", session: 1)]
        
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
            // Note: lastModified is handled by the change tracking system
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
            // Note: lastModified is handled by the change tracking system
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
            // Note: lastModified is handled by the change tracking system
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
            // Note: lastModified is handled by the change tracking system
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
            // Note: lastModified is handled by the change tracking system
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
            // Note: lastModified is handled by the change tracking system
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
            // Note: lastModified is handled by the change tracking system
        }
    }
    
    // MARK: - New Skill-Based Specialization System
    
    /// New skill-based specialization storage: [SkillName: [SpecializationName: Advances]]
    /// A value of 0 means the specialization should not be displayed
    var skillSpecializations: [String: [String: Int]] {
        get {
            // Handle empty string case explicitly
            guard !skillSpecializationsData.isEmpty else {
                return [:]
            }
            
            guard let data = skillSpecializationsData.data(using: .utf8),
                  let decoded = try? JSONDecoder().decode([String: [String: Int]].self, from: data) else {
                return [:]
            }
            return decoded
        }
        set {
            if let encoded = try? JSONEncoder().encode(newValue) {
                skillSpecializationsData = String(data: encoded, encoding: .utf8) ?? ""
            } else {
                // Fallback in case encoding fails
                skillSpecializationsData = ""
            }
        }
    }
    
    /// Gets the advances for a specific specialization of a specific skill
    func getSpecializationAdvances(specialization: String, skill: String) -> Int {
        return skillSpecializations[skill]?[specialization] ?? 0
    }
    
    /// Sets the advances for a specific specialization of a specific skill
    /// If advances is 0, the specialization is hidden but not removed
    func setSpecializationAdvances(specialization: String, skill: String, advances: Int) {
        var specializations = skillSpecializations
        
        if specializations[skill] == nil {
            specializations[skill] = [:]
        }
        
        specializations[skill]?[specialization] = advances
        skillSpecializations = specializations
    }
    
    /// Deletes a specialization by setting its advances to 0
    func deleteSpecialization(specialization: String, skill: String) {
        setSpecializationAdvances(specialization: specialization, skill: skill, advances: 0)
    }
    
    /// Gets all visible specializations (advances > 0) for display
    func getVisibleSpecializations() -> [(name: String, skill: String, advances: Int)] {
        var result: [(name: String, skill: String, advances: Int)] = []
        
        for (skillName, specializations) in skillSpecializations {
            for (specializationName, advances) in specializations {
                if advances > 0 {
                    result.append((name: specializationName, skill: skillName, advances: advances))
                }
            }
        }
        
        // Stable sort: first by specialization name, then by skill name
        return result.sorted { 
            if $0.name == $1.name {
                return $0.skill < $1.skill
            }
            return $0.name < $1.name 
        }
    }
    
    /// Migrates from old composite key system to new skill-based system
    func migrateFromLegacySpecializations() {
        // Only migrate if new system is empty and old system has data
        guard (skillSpecializationsData.isEmpty || skillSpecializations.isEmpty) &&
              !specializationAdvancesData.isEmpty else {
            return
        }
        
        let legacyAdvances = specializationAdvances
        var newSpecializations: [String: [String: Int]] = [:]
        
        for (key, advances) in legacyAdvances {
            if advances > 0 {
                let parsed = ImperiumCharacter.parseSpecializationKey(key)
                let specializationName = parsed.specialization
                let skillName = parsed.skill ?? SkillSpecializations.findSkillForSpecialization(specializationName)
                
                if skillName != "Unknown" {
                    if newSpecializations[skillName] == nil {
                        newSpecializations[skillName] = [:]
                    }
                    newSpecializations[skillName]?[specializationName] = advances
                }
            }
        }
        
        skillSpecializations = newSpecializations
    }
    
    // MARK: - Legacy Compatibility (Keep for backwards compatibility)
    
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
        }
    }
    
    /// Creates a composite key for a specialization that includes the skill name to avoid ambiguity
    /// For example: "Human (Intuition)" or "Forbidden (Lore)"
    static func makeSpecializationKey(specialization: String, skill: String) -> String {
        return "\(specialization) (\(skill))"
    }
    
    /// Parses a composite specialization key to extract the specialization name and skill
    /// Returns (specializationName, skillName) or (originalKey, nil) if parsing fails
    static func parseSpecializationKey(_ key: String) -> (specialization: String, skill: String?) {
        // Check if it has the format "Name (Skill)"
        if let parenRange = key.range(of: " ("),
           key.hasSuffix(")") {
            let specializationName = String(key[..<parenRange.lowerBound])
            let skillStart = key.index(parenRange.upperBound, offsetBy: 0)
            let skillEnd = key.index(before: key.endIndex)
            let skillName = String(key[skillStart..<skillEnd])
            return (specializationName, skillName)
        }
        // Return the original key as specialization name with no skill if parsing fails
        return (key, nil)
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
            // Note: lastModified is handled by the change tracking system
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
            // Note: lastModified is handled by the change tracking system
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
            // Note: lastModified is handled by the change tracking system
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
            // Note: lastModified is handled by the change tracking system
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
            // Note: lastModified is handled by the change tracking system
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
            // Note: lastModified is handled by the change tracking system
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
            // Note: lastModified is handled by the change tracking system
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
            // Note: lastModified is handled by the change tracking system
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
            // Note: lastModified is handled by the change tracking system
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
            // Note: lastModified is handled by the change tracking system
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
            // Note: lastModified is handled by the change tracking system
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
            // Note: lastModified is handled by the change tracking system
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
            // Note: lastModified is handled by the change tracking system
        }
    }
    
    // MARK: - Migration Methods
    
    /// Migrates equipment and weapons from string arrays to proper Equipment/Weapon objects
    func migrateEquipmentAndWeapons() {
        // Migrate from old string-based data to new object-based system
        if !equipmentNames.isEmpty && equipmentList.isEmpty {
            var newEquipmentList: [Equipment] = []
            
            for equipmentName in equipmentNames {
                if isWeaponItem(equipmentName) {
                    // This should be a weapon, add it to weapon list instead
                    let weapon = parseWeaponFromName(equipmentName)
                    var currentWeaponList = weaponList
                    currentWeaponList.append(weapon)
                    weaponList = currentWeaponList
                } else {
                    // Parse equipment from name
                    let equipment = parseEquipmentFromName(equipmentName)
                    newEquipmentList.append(equipment)
                }
            }
            
            if !newEquipmentList.isEmpty {
                equipmentList = newEquipmentList
            }
            // Keep old data for backward compatibility
        }
        
        if !weaponNames.isEmpty && weaponList.isEmpty {
            var newWeaponList: [Weapon] = []
            
            for weaponName in weaponNames {
                // Parse weapon from name
                let weapon = parseWeaponFromName(weaponName)
                newWeaponList.append(weapon)
            }
            
            weaponList = newWeaponList
            // Keep old data for backward compatibility
        }
        
        // Fix existing Equipment objects that might have full names instead of base names
        var updatedEquipmentList: [Equipment] = []
        for equipment in equipmentList {
            if equipment.name.contains("(") && equipment.name.contains(")") {
                // This equipment has a full name like "Writing Kit (Shoddy)"
                // Re-parse it to extract base name and traits
                let reparsedEquipment = parseEquipmentFromName(equipment.name)
                updatedEquipmentList.append(reparsedEquipment)
            } else {
                // This equipment already has a base name, keep it as is
                updatedEquipmentList.append(equipment)
            }
        }
        
        if updatedEquipmentList.count > 0 {
            equipmentList = updatedEquipmentList
        }
        
        // Fix existing Weapon objects that might have full names instead of base names
        var updatedWeaponList: [Weapon] = []
        for weapon in weaponList {
            if weapon.name.contains("(") && weapon.name.contains(")") {
                // This weapon has a full name, re-parse it
                let reparsedWeapon = parseWeaponFromName(weapon.name)
                updatedWeaponList.append(reparsedWeapon)
            } else {
                // This weapon already has a base name, keep it as is
                updatedWeaponList.append(weapon)
            }
        }
        
        if updatedWeaponList.count > 0 {
            weaponList = updatedWeaponList
        }
        
        // Migrate categories for existing weapons
        for weapon in weaponList {
            weapon.migrateCategory()
        }
        
        // Note: Equipment and Weapon objects created before UUID addition will get 
        // auto-generated UUIDs through the Codable system, so no explicit migration needed
        
        lastModified = Date()
    }
    
    private func isWeaponItem(_ itemName: String) -> Bool {
        let baseName = parseBaseName(itemName).lowercased()
        let weaponKeywords = ["knife", "sword", "gun", "pistol", "rifle", "blade", "axe", "hammer", "mace", "spear", "staff", "bow", "crossbow", "grenade", "launcher", "cannon"]
        
        return weaponKeywords.contains { baseName.contains($0) }
    }
    
    private func parseBaseName(_ fullName: String) -> String {
        // Extract the base name before any parentheses
        if let range = fullName.range(of: " (") {
            return String(fullName[..<range.lowerBound]).trimmingCharacters(in: .whitespacesAndNewlines)
        }
        return fullName.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    private func parseParenthesesContent(_ fullName: String) -> [String] {
        // Extract content from parentheses
        var content: [String] = []
        var currentIndex = fullName.startIndex
        
        while currentIndex < fullName.endIndex {
            if let openRange = fullName.range(of: "(", range: currentIndex..<fullName.endIndex),
               let closeRange = fullName.range(of: ")", range: openRange.upperBound..<fullName.endIndex) {
                let contentString = String(fullName[openRange.upperBound..<closeRange.lowerBound])
                content.append(contentString.trimmingCharacters(in: .whitespacesAndNewlines))
                currentIndex = closeRange.upperBound
            } else {
                break
            }
        }
        
        return content
    }
    
    private func parseEquipmentFromName(_ fullName: String) -> Equipment {
        let baseName = parseBaseName(fullName)
        let parenthesesContent = parseParenthesesContent(fullName)
        
        // Try to get equipment from template first
        let equipment: Equipment
        if let template = EquipmentTemplateDefinitions.getTemplate(for: baseName) {
            equipment = template.createEquipment()
            // Use the base name to keep equipment items with same base name grouped together
            equipment.name = baseName
        } else {
            equipment = Equipment(name: baseName)
        }
        
        // Parse qualities, flaws, and traits from parentheses
        for content in parenthesesContent {
            if EquipmentQualities.all.contains(content) {
                var qualities = equipment.qualities
                qualities.append(content)
                equipment.qualities = qualities
            } else if EquipmentFlaws.all.contains(content) {
                var flaws = equipment.flaws
                flaws.append(content)
                equipment.flaws = flaws
            } else if EquipmentTraitNames.all.contains(content) {
                var traits = equipment.traits
                traits.append(EquipmentTrait(name: content))
                equipment.traits = traits
            }
        }
        
        return equipment
    }
    
    private func parseWeaponFromName(_ fullName: String) -> Weapon {
        let baseName = parseBaseName(fullName)
        let parenthesesContent = parseParenthesesContent(fullName)
        
        // Try to get weapon from template first
        let weapon: Weapon
        if let template = WeaponTemplateDefinitions.getTemplate(for: baseName) {
            weapon = template.createWeapon()
            // Use the base name to keep weapon items with same base name grouped together
            weapon.name = baseName
        } else {
            weapon = Weapon(name: baseName)
        }
        
        // Parse modifications, qualities, flaws, and traits from parentheses
        for content in parenthesesContent {
            if WeaponModifications.all.contains(content) {
                var modifications = weapon.modifications
                modifications.append(content)
                weapon.modifications = modifications
            } else if EquipmentQualities.all.contains(content) {
                var qualities = weapon.qualities
                qualities.append(content)
                weapon.qualities = qualities
            } else if EquipmentFlaws.all.contains(content) {
                var flaws = weapon.flaws
                flaws.append(content)
                weapon.flaws = flaws
            } else if WeaponTraitNames.all.contains(content) {
                var traits = weapon.weaponTraits
                traits.append(WeaponTrait(name: content))
                weapon.weaponTraits = traits
            }
        }
        
        return weapon
    }
    
    // MARK: - Change History Management
    
    func addChangeLogEntry(_ summary: String) {
        let entry = ChangeLogEntry(summary: summary, session: currentSession)
        changeLog.append(entry)
        lastModified = Date()
    }
    
    func incrementSession() {
        currentSession += 1
        addChangeLogEntry("Session incremented to \(currentSession)")
    }
    
    func decrementSession() {
        if currentSession > 1 {
            currentSession -= 1
            addChangeLogEntry("Session decremented to \(currentSession)")
        }
    }
    
    func generateChangeSummary(originalCharacter: ImperiumCharacter) -> [String] {
        var changes: [String] = []
        
        // Check basic information changes (excluding corruption and non-critical wounds)
        if name != originalCharacter.name {
            changes.append("name \(originalCharacter.name)→\(name)")
        }
        if player != originalCharacter.player {
            changes.append("player \(originalCharacter.player)→\(player)")
        }
        if campaign != originalCharacter.campaign {
            changes.append("campaign \(originalCharacter.campaign)→\(campaign)")
        }
        if faction != originalCharacter.faction {
            changes.append("faction \(originalCharacter.faction)→\(faction)")
        }
        if role != originalCharacter.role {
            changes.append("role \(originalCharacter.role)→\(role)")
        }
        if homeworld != originalCharacter.homeworld {
            changes.append("homeworld \(originalCharacter.homeworld)→\(homeworld)")
        }
        if background != originalCharacter.background {
            changes.append("background \(originalCharacter.background)→\(background)")
        }
        if shortTermGoal != originalCharacter.shortTermGoal {
            changes.append("short-term goals: \(shortTermGoal)")
        }
        if longTermGoal != originalCharacter.longTermGoal {
            changes.append("long-term goals: \(longTermGoal)")
        }
        if characterDescription != originalCharacter.characterDescription {
            changes.append("character description: \(characterDescription)")
        }
        if notes != originalCharacter.notes {
            changes.append("notes: \(notes)")
        }
        
        // Check characteristics changes (new system)
        let characteristicsChanges = getDetailedCharacteristicsChanges(originalCharacter: originalCharacter)
        changes.append(contentsOf: characteristicsChanges)
        
        // Check legacy characteristics for backward compatibility
        if weaponSkill != originalCharacter.weaponSkill {
            changes.append("weapon skill \(originalCharacter.weaponSkill)→\(weaponSkill)")
        }
        if ballisticSkill != originalCharacter.ballisticSkill {
            changes.append("ballistic skill \(originalCharacter.ballisticSkill)→\(ballisticSkill)")
        }
        if strength != originalCharacter.strength {
            changes.append("strength \(originalCharacter.strength)→\(strength)")
        }
        if toughness != originalCharacter.toughness {
            changes.append("toughness \(originalCharacter.toughness)→\(toughness)")
        }
        if agility != originalCharacter.agility {
            changes.append("agility \(originalCharacter.agility)→\(agility)")
        }
        if intelligence != originalCharacter.intelligence {
            changes.append("intelligence \(originalCharacter.intelligence)→\(intelligence)")
        }
        if willpower != originalCharacter.willpower {
            changes.append("willpower \(originalCharacter.willpower)→\(willpower)")
        }
        if fellowship != originalCharacter.fellowship {
            changes.append("fellowship \(originalCharacter.fellowship)→\(fellowship)")
        }
        if influence != originalCharacter.influence {
            changes.append("influence \(originalCharacter.influence)→\(influence)")
        }
        if perception != originalCharacter.perception {
            changes.append("perception \(originalCharacter.perception)→\(perception)")
        }
        
        // Check other stats (excluding corruption and wounds - as specified in requirements)
        if fate != originalCharacter.fate {
            changes.append("fate \(originalCharacter.fate)→\(fate)")
        }
        if spentFate != originalCharacter.spentFate {
            changes.append("spent fate \(originalCharacter.spentFate)→\(spentFate)")
        }
        if solars != originalCharacter.solars {
            changes.append("solars \(originalCharacter.solars)→\(solars)")
        }
        
        // Check experience changes
        if totalExperience != originalCharacter.totalExperience {
            changes.append("total experience \(originalCharacter.totalExperience)→\(totalExperience)")
        }
        if spentExperience != originalCharacter.spentExperience {
            changes.append("spent experience \(originalCharacter.spentExperience)→\(spentExperience)")
        }
        
        // Check critical wounds (as this is different from non-critical wounds)
        if criticalWounds != originalCharacter.criticalWounds {
            changes.append("critical wounds \(originalCharacter.criticalWounds)→\(criticalWounds)")
        }
        
        // Check injuries lists changes  
        let injuryChanges = getDetailedInjuryChanges(originalCharacter: originalCharacter)
        changes.append(contentsOf: injuryChanges)
        
        // Check conditions
        let conditionChanges = getDetailedConditionChanges(originalCharacter: originalCharacter)
        changes.append(contentsOf: conditionChanges)
        
        // Check skills, talents, equipment changes with specific details
        let skillAdvancesChanges = getDetailedSkillAdvancesChanges(originalCharacter: originalCharacter)
        changes.append(contentsOf: skillAdvancesChanges)
        
        let factionSkillAdvancesChanges = getDetailedFactionSkillAdvancesChanges(originalCharacter: originalCharacter)
        changes.append(contentsOf: factionSkillAdvancesChanges)
        
        let specializationAdvancesChanges = getDetailedSpecializationAdvancesChanges(originalCharacter: originalCharacter)
        changes.append(contentsOf: specializationAdvancesChanges)
        
        let talentChanges = getDetailedTalentChanges(originalCharacter: originalCharacter)
        changes.append(contentsOf: talentChanges)
        
        let equipmentChanges = getDetailedEquipmentChanges(originalCharacter: originalCharacter)
        changes.append(contentsOf: equipmentChanges)
        
        let weaponChanges = getDetailedWeaponChanges(originalCharacter: originalCharacter)
        changes.append(contentsOf: weaponChanges)
        
        let psychicPowerChanges = getDetailedPsychicPowerChanges(originalCharacter: originalCharacter)
        changes.append(contentsOf: psychicPowerChanges)
        
        let reputationChanges = getDetailedReputationChanges(originalCharacter: originalCharacter)
        changes.append(contentsOf: reputationChanges)
        
        return changes
    }
    
    func logChanges(originalCharacter: ImperiumCharacter) {
        let changes = generateChangeSummary(originalCharacter: originalCharacter)
        if !changes.isEmpty {
            let summary = changes.joined(separator: ", ")
            addChangeLogEntry(summary)
        }
    }
    
    // MARK: - Detailed Change Tracking Helpers
    
    private func getDetailedCharacteristicsChanges(originalCharacter: ImperiumCharacter) -> [String] {
        guard characteristicsData != originalCharacter.characteristicsData else { return [] }
        
        var changes: [String] = []
        let currentCharacteristics = characteristics
        let originalCharacteristics = originalCharacter.characteristics
        
        // Check for changes in characteristics
        for (name, currentChar) in currentCharacteristics {
            if let originalChar = originalCharacteristics[name] {
                // Check initial value changes
                if currentChar.initialValue != originalChar.initialValue {
                    changes.append("\(name.lowercased()) base \(originalChar.initialValue)→\(currentChar.initialValue)")
                }
                // Check advances changes
                if currentChar.advances != originalChar.advances {
                    changes.append("\(name.lowercased()) advances \(originalChar.advances)→\(currentChar.advances)")
                }
            } else {
                // New characteristic added
                changes.append("\(name.lowercased()) added: base \(currentChar.initialValue), advances \(currentChar.advances)")
            }
        }
        
        // Check for removed characteristics
        for (name, originalChar) in originalCharacteristics {
            if currentCharacteristics[name] == nil {
                changes.append("\(name.lowercased()) removed (base \(originalChar.initialValue), advances \(originalChar.advances))")
            }
        }
        
        return changes
    }
    
    private func getDetailedSkillAdvancesChanges(originalCharacter: ImperiumCharacter) -> [String] {
        guard skillsAdvancesData != originalCharacter.skillsAdvancesData else { return [] }
        
        var changes: [String] = []
        let currentAdvances = skillAdvances
        let originalAdvances = originalCharacter.skillAdvances
        
        // Find added/changed skills
        for (skill, currentValue) in currentAdvances {
            let originalValue = originalAdvances[skill] ?? 0
            if currentValue != originalValue {
                changes.append("skill \(skill) \(originalValue)→\(currentValue)")
            }
        }
        
        // Find removed skills
        for (skill, originalValue) in originalAdvances {
            if currentAdvances[skill] == nil {
                changes.append("skill \(skill) removed (\(originalValue)→0)")
            }
        }
        
        return changes
    }
    
    private func getDetailedFactionSkillAdvancesChanges(originalCharacter: ImperiumCharacter) -> [String] {
        guard factionSkillAdvancesData != originalCharacter.factionSkillAdvancesData else { return [] }
        
        var changes: [String] = []
        let currentAdvances = factionSkillAdvances
        let originalAdvances = originalCharacter.factionSkillAdvances
        
        // Find added/changed faction skills
        for (skill, currentValue) in currentAdvances {
            let originalValue = originalAdvances[skill] ?? 0
            if currentValue != originalValue {
                changes.append("faction skill \(skill) \(originalValue)→\(currentValue)")
            }
        }
        
        // Find removed faction skills
        for (skill, originalValue) in originalAdvances {
            if currentAdvances[skill] == nil {
                changes.append("faction skill \(skill) removed (\(originalValue)→0)")
            }
        }
        
        return changes
    }
    
    private func getDetailedSpecializationAdvancesChanges(originalCharacter: ImperiumCharacter) -> [String] {
        // Check both old and new systems for changes
        let hasLegacyChanges = specializationAdvancesData != originalCharacter.specializationAdvancesData
        let hasNewChanges = skillSpecializationsData != originalCharacter.skillSpecializationsData
        
        guard hasLegacyChanges || hasNewChanges else { return [] }
        
        var changes: [String] = []
        
        // Use new system if it has data, otherwise fall back to legacy
        if !skillSpecializationsData.isEmpty || !originalCharacter.skillSpecializationsData.isEmpty {
            let currentSpecs = skillSpecializations
            let originalSpecs = originalCharacter.skillSpecializations
            
            // Find added/changed specializations
            for (skill, specializations) in currentSpecs {
                for (specName, currentValue) in specializations {
                    let originalValue = originalSpecs[skill]?[specName] ?? 0
                    if currentValue != originalValue && currentValue > 0 {
                        changes.append("specialization \(specName) (\(skill)) \(originalValue)→\(currentValue)")
                    }
                }
            }
            
            // Find removed specializations (set to 0)
            for (skill, originalSpecializations) in originalSpecs {
                for (specName, originalValue) in originalSpecializations {
                    let currentValue = currentSpecs[skill]?[specName] ?? 0
                    if originalValue > 0 && currentValue == 0 {
                        changes.append("specialization \(specName) (\(skill)) removed (\(originalValue)→0)")
                    }
                }
            }
        } else {
            // Fall back to legacy system
            let currentAdvances = specializationAdvances
            let originalAdvances = originalCharacter.specializationAdvances
            
            // Find added/changed specialization advances
            for (specialization, currentValue) in currentAdvances {
                let originalValue = originalAdvances[specialization] ?? 0
                if currentValue != originalValue {
                    changes.append("specialization \(specialization) \(originalValue)→\(currentValue)")
                }
            }
            
            // Find removed specialization advances
            for (specialization, originalValue) in originalAdvances {
                if currentAdvances[specialization] == nil {
                    changes.append("specialization \(specialization) removed (\(originalValue)→0)")
                }
            }
        }
        
        return changes
    }
    
    private func getDetailedTalentChanges(originalCharacter: ImperiumCharacter) -> [String] {
        guard talentNamesData != originalCharacter.talentNamesData else { return [] }
        
        var changes: [String] = []
        let currentTalents = Set(talentNames)
        let originalTalents = Set(originalCharacter.talentNames)
        
        // Find added talents
        let addedTalents = currentTalents.subtracting(originalTalents)
        for talent in addedTalents.sorted() {
            changes.append("talent added: \(talent)")
        }
        
        // Find removed talents
        let removedTalents = originalTalents.subtracting(currentTalents)
        for talent in removedTalents.sorted() {
            changes.append("talent removed: \(talent)")
        }
        
        return changes
    }
    
    private func getDetailedEquipmentChanges(originalCharacter: ImperiumCharacter) -> [String] {
        guard equipmentListData != originalCharacter.equipmentListData else { return [] }
        
        var changes: [String] = []
        let currentEquipment = equipmentList
        let originalEquipment = originalCharacter.equipmentList
        
        // Create sets of equipment IDs for comparison
        let currentIds = Set(currentEquipment.map { $0.id })
        let originalIds = Set(originalEquipment.map { $0.id })
        
        // Find added equipment
        let addedIds = currentIds.subtracting(originalIds)
        for addedId in addedIds {
            if let equipment = currentEquipment.first(where: { $0.id == addedId }) {
                changes.append("equipment added: \(equipment.name)")
            }
        }
        
        // Find removed equipment
        let removedIds = originalIds.subtracting(currentIds)
        for removedId in removedIds {
            if let equipment = originalEquipment.first(where: { $0.id == removedId }) {
                changes.append("equipment removed: \(equipment.name)")
            }
        }
        
        return changes
    }
    
    private func getDetailedWeaponChanges(originalCharacter: ImperiumCharacter) -> [String] {
        guard weaponListData != originalCharacter.weaponListData else { return [] }
        
        var changes: [String] = []
        let currentWeapons = weaponList
        let originalWeapons = originalCharacter.weaponList
        
        // Create sets of weapon IDs for comparison
        let currentIds = Set(currentWeapons.map { $0.id })
        let originalIds = Set(originalWeapons.map { $0.id })
        
        // Find added weapons
        let addedIds = currentIds.subtracting(originalIds)
        for addedId in addedIds {
            if let weapon = currentWeapons.first(where: { $0.id == addedId }) {
                changes.append("weapon added: \(weapon.name)")
            }
        }
        
        // Find removed weapons
        let removedIds = originalIds.subtracting(currentIds)
        for removedId in removedIds {
            if let weapon = originalWeapons.first(where: { $0.id == removedId }) {
                changes.append("weapon removed: \(weapon.name)")
            }
        }
        
        return changes
    }
    
    private func getDetailedPsychicPowerChanges(originalCharacter: ImperiumCharacter) -> [String] {
        guard psychicPowersData != originalCharacter.psychicPowersData else { return [] }
        
        var changes: [String] = []
        let currentPowers = Set(psychicPowers)
        let originalPowers = Set(originalCharacter.psychicPowers)
        
        // Find added psychic powers
        let addedPowers = currentPowers.subtracting(originalPowers)
        for power in addedPowers.sorted() {
            changes.append("psychic power added: \(power)")
        }
        
        // Find removed psychic powers
        let removedPowers = originalPowers.subtracting(currentPowers)
        for power in removedPowers.sorted() {
            changes.append("psychic power removed: \(power)")
        }
        
        return changes
    }
    
    private func getDetailedReputationChanges(originalCharacter: ImperiumCharacter) -> [String] {
        guard reputationData != originalCharacter.reputationData else { return [] }
        
        var changes: [String] = []
        let currentReputations = reputations
        let originalReputations = originalCharacter.reputations
        
        // Create dictionaries using composite keys (faction + individual) for easier comparison
        let currentDict = Dictionary(uniqueKeysWithValues: currentReputations.map { 
            ("\($0.faction)|\($0.individual)", ($0, $0.value)) 
        })
        let originalDict = Dictionary(uniqueKeysWithValues: originalReputations.map { 
            ("\($0.faction)|\($0.individual)", ($0, $0.value)) 
        })
        
        // Find added/changed reputations
        for (compositeKey, (reputation, currentValue)) in currentDict {
            let originalValue = originalDict[compositeKey]?.1 ?? 0
            if currentValue != originalValue {
                let displayName = reputation.individual.isEmpty ? reputation.faction : reputation.individual
                changes.append("reputation \(displayName) \(originalValue)→\(currentValue)")
            }
        }
        
        // Find removed reputations
        for (compositeKey, (reputation, originalValue)) in originalDict {
            if currentDict[compositeKey] == nil {
                let displayName = reputation.individual.isEmpty ? reputation.faction : reputation.individual
                changes.append("reputation \(displayName) removed (\(originalValue)→0)")
            }
        }
        
        return changes
    }
    
    private func getDetailedInjuryChanges(originalCharacter: ImperiumCharacter) -> [String] {
        var changes: [String] = []
        
        // Head injuries
        if headInjuries != originalCharacter.headInjuries {
            let currentInjuries = Set(headInjuriesList.map { $0.name })
            let originalInjuries = Set(originalCharacter.headInjuriesList.map { $0.name })
            
            // Find added head injuries
            let addedInjuries = currentInjuries.subtracting(originalInjuries)
            for injury in addedInjuries.sorted() {
                changes.append("head injury added: \(injury)")
            }
            
            // Find removed head injuries
            let removedInjuries = originalInjuries.subtracting(currentInjuries)
            for injury in removedInjuries.sorted() {
                changes.append("head injury removed: \(injury)")
            }
        }
        
        // Arm injuries
        if armInjuries != originalCharacter.armInjuries {
            let currentInjuries = Set(armInjuriesList.map { $0.name })
            let originalInjuries = Set(originalCharacter.armInjuriesList.map { $0.name })
            
            // Find added arm injuries
            let addedInjuries = currentInjuries.subtracting(originalInjuries)
            for injury in addedInjuries.sorted() {
                changes.append("arm injury added: \(injury)")
            }
            
            // Find removed arm injuries
            let removedInjuries = originalInjuries.subtracting(currentInjuries)
            for injury in removedInjuries.sorted() {
                changes.append("arm injury removed: \(injury)")
            }
        }
        
        // Body injuries
        if bodyInjuries != originalCharacter.bodyInjuries {
            let currentInjuries = Set(bodyInjuriesList.map { $0.name })
            let originalInjuries = Set(originalCharacter.bodyInjuriesList.map { $0.name })
            
            // Find added body injuries
            let addedInjuries = currentInjuries.subtracting(originalInjuries)
            for injury in addedInjuries.sorted() {
                changes.append("body injury added: \(injury)")
            }
            
            // Find removed body injuries
            let removedInjuries = originalInjuries.subtracting(currentInjuries)
            for injury in removedInjuries.sorted() {
                changes.append("body injury removed: \(injury)")
            }
        }
        
        // Leg injuries
        if legInjuries != originalCharacter.legInjuries {
            let currentInjuries = Set(legInjuriesList.map { $0.name })
            let originalInjuries = Set(originalCharacter.legInjuriesList.map { $0.name })
            
            // Find added leg injuries
            let addedInjuries = currentInjuries.subtracting(originalInjuries)
            for injury in addedInjuries.sorted() {
                changes.append("leg injury added: \(injury)")
            }
            
            // Find removed leg injuries
            let removedInjuries = originalInjuries.subtracting(currentInjuries)
            for injury in removedInjuries.sorted() {
                changes.append("leg injury removed: \(injury)")
            }
        }
        
        return changes
    }
    
    private func getDetailedConditionChanges(originalCharacter: ImperiumCharacter) -> [String] {
        guard conditionsData != originalCharacter.conditionsData else { return [] }
        
        var changes: [String] = []
        let currentConditions = Set(conditionsList.map { $0.name })
        let originalConditions = Set(originalCharacter.conditionsList.map { $0.name })
        
        // Find added conditions
        let addedConditions = currentConditions.subtracting(originalConditions)
        for condition in addedConditions.sorted() {
            changes.append("condition added: \(condition)")
        }
        
        // Find removed conditions
        let removedConditions = originalConditions.subtracting(currentConditions)
        for condition in removedConditions.sorted() {
            changes.append("condition removed: \(condition)")
        }
        
        return changes
    }
}