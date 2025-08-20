//
//  CharacterSnapshot.swift
//  ImperiumMaledictumCharacter
//
//  Created by User on 20.08.2025.
//

import Foundation

/// A lightweight snapshot of character data for change tracking purposes
class CharacterSnapshot {
    // Basic character info
    let name: String
    let player: String
    let campaign: String
    let faction: String
    let role: String
    let homeworld: String
    let background: String
    let shortTermGoal: String
    let longTermGoal: String
    let characterDescription: String
    
    // Characteristics
    let weaponSkill: Int
    let ballisticSkill: Int
    let strength: Int
    let toughness: Int
    let agility: Int
    let intelligence: Int
    let willpower: Int
    let fellowship: Int
    let influence: Int
    let perception: Int
    
    // Derived stats (excluding corruption and wounds per requirements)
    let fate: Int
    let spentFate: Int
    let solars: Int
    let totalExperience: Int
    let spentExperience: Int
    let criticalWounds: Int
    
    // Data strings for complex objects
    let characteristicsData: String
    let skillsAdvancesData: String
    let factionSkillAdvancesData: String
    let specializationAdvancesData: String
    let talentNamesData: String
    let equipmentListData: String
    let weaponListData: String
    let psychicPowersData: String
    let reputationData: String
    let headInjuries: String
    let armInjuries: String
    let bodyInjuries: String
    let legInjuries: String
    let conditionsData: String
    
    init(from character: ImperiumCharacter) {
        // Basic info
        self.name = character.name
        self.player = character.player
        self.campaign = character.campaign
        self.faction = character.faction
        self.role = character.role
        self.homeworld = character.homeworld
        self.background = character.background
        self.shortTermGoal = character.shortTermGoal
        self.longTermGoal = character.longTermGoal
        self.characterDescription = character.characterDescription
        
        // Characteristics
        self.weaponSkill = character.weaponSkill
        self.ballisticSkill = character.ballisticSkill
        self.strength = character.strength
        self.toughness = character.toughness
        self.agility = character.agility
        self.intelligence = character.intelligence
        self.willpower = character.willpower
        self.fellowship = character.fellowship
        self.influence = character.influence
        self.perception = character.perception
        
        // Derived stats
        self.fate = character.fate
        self.spentFate = character.spentFate
        self.solars = character.solars
        self.totalExperience = character.totalExperience
        self.spentExperience = character.spentExperience
        self.criticalWounds = character.criticalWounds
        
        // Complex data
        self.characteristicsData = character.characteristicsData
        self.skillsAdvancesData = character.skillsAdvancesData
        self.factionSkillAdvancesData = character.factionSkillAdvancesData
        self.specializationAdvancesData = character.specializationAdvancesData
        self.talentNamesData = character.talentNamesData
        self.equipmentListData = character.equipmentListData
        self.weaponListData = character.weaponListData
        self.psychicPowersData = character.psychicPowersData
        self.reputationData = character.reputationData
        self.headInjuries = character.headInjuries
        self.armInjuries = character.armInjuries
        self.bodyInjuries = character.bodyInjuries
        self.legInjuries = character.legInjuries
        self.conditionsData = character.conditionsData
    }
    
    func applyTo(_ character: ImperiumCharacter) {
        // Basic info
        character.name = self.name
        character.player = self.player
        character.campaign = self.campaign
        character.faction = self.faction
        character.role = self.role
        character.homeworld = self.homeworld
        character.background = self.background
        character.shortTermGoal = self.shortTermGoal
        character.longTermGoal = self.longTermGoal
        character.characterDescription = self.characterDescription
        
        // Characteristics
        character.weaponSkill = self.weaponSkill
        character.ballisticSkill = self.ballisticSkill
        character.strength = self.strength
        character.toughness = self.toughness
        character.agility = self.agility
        character.intelligence = self.intelligence
        character.willpower = self.willpower
        character.fellowship = self.fellowship
        character.influence = self.influence
        character.perception = self.perception
        
        // Derived stats
        character.fate = self.fate
        character.spentFate = self.spentFate
        character.solars = self.solars
        character.totalExperience = self.totalExperience
        character.spentExperience = self.spentExperience
        character.criticalWounds = self.criticalWounds
        
        // Complex data
        character.characteristicsData = self.characteristicsData
        character.skillsAdvancesData = self.skillsAdvancesData
        character.factionSkillAdvancesData = self.factionSkillAdvancesData
        character.specializationAdvancesData = self.specializationAdvancesData
        character.talentNamesData = self.talentNamesData
        character.equipmentListData = self.equipmentListData
        character.weaponListData = self.weaponListData
        character.psychicPowersData = self.psychicPowersData
        character.reputationData = self.reputationData
        character.headInjuries = self.headInjuries
        character.armInjuries = self.armInjuries
        character.bodyInjuries = self.bodyInjuries
        character.legInjuries = self.legInjuries
        character.conditionsData = self.conditionsData
    }
}