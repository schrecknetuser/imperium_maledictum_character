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
        if goal != originalCharacter.goal {
            changes.append("goal \(originalCharacter.goal)→\(goal)")
        }
        if nemesis != originalCharacter.nemesis {
            changes.append("nemesis \(originalCharacter.nemesis)→\(nemesis)")
        }
        if shortTermGoal != originalCharacter.shortTermGoal {
            changes.append("short term goal updated")
        }
        if longTermGoal != originalCharacter.longTermGoal {
            changes.append("long term goal updated")
        }
        if characterDescription != originalCharacter.characterDescription {
            changes.append("character description updated")
        }
        
        // Check characteristics changes
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
        
        // Check other stats (excluding corruption - as specified in requirements)
        if wounds != originalCharacter.wounds {
            changes.append("wounds \(originalCharacter.wounds)→\(wounds)")
        }
        if stress != originalCharacter.stress {
            changes.append("stress \(originalCharacter.stress)→\(stress)")
        }
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
        if headInjuries != originalCharacter.headInjuries {
            changes.append("head injuries changed")
        }
        if armInjuries != originalCharacter.armInjuries {
            changes.append("arm injuries changed")
        }
        if bodyInjuries != originalCharacter.bodyInjuries {
            changes.append("body injuries changed")
        }
        if legInjuries != originalCharacter.legInjuries {
            changes.append("leg injuries changed")
        }
        
        // Check conditions
        if conditionsData != originalCharacter.conditionsData {
            changes.append("conditions changed")
        }
        
        // Check skills, talents, equipment changes
        if skillsAdvancesData != originalCharacter.skillsAdvancesData {
            changes.append("skill advances changed")
        }
        if factionSkillAdvancesData != originalCharacter.factionSkillAdvancesData {
            changes.append("faction skill advances changed")
        }
        if specializationAdvancesData != originalCharacter.specializationAdvancesData {
            changes.append("specialization advances changed")
        }
        if talentNamesData != originalCharacter.talentNamesData {
            changes.append("talents changed")
        }
        if equipmentListData != originalCharacter.equipmentListData {
            changes.append("equipment changed")
        }
        if weaponListData != originalCharacter.weaponListData {
            changes.append("weapons changed")
        }
        if psychicPowersData != originalCharacter.psychicPowersData {
            changes.append("psychic powers changed")
        }
        if reputationData != originalCharacter.reputationData {
            changes.append("reputation changed")
        }
        
        return changes
    }
    
    func logChanges(originalCharacter: ImperiumCharacter) {
        let changes = generateChangeSummary(originalCharacter: originalCharacter)
        if !changes.isEmpty {
            let summary = changes.joined(separator: ", ")
            addChangeLogEntry(summary)
        }
    }
}