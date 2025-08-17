//
//  ConditionModel.swift
//  ImperiumMaledictumCharacter
//
//  Created by User on 11.01.2025.
//

import Foundation

struct Condition: Codable, Identifiable {
    var id: UUID = UUID()
    let name: String
    let description: String
    
    init(name: String, description: String) {
        self.id = UUID()
        self.name = name
        self.description = description
    }
    
    enum CodingKeys: String, CodingKey {
        case name, description
    }
}

// MARK: - Condition Definitions

struct ConditionDefinitions {
    
    static let allConditions = [
        Condition(
            name: "Ablaze (Minor)",
            description: "You suffer 1d5 Damage at the start of your turn, which ignores armour. White you are Ablaze, you automatically fail all Stealth Tests. Unless specified otherwise, you may remove an Ablaze condition by dropping Prone and using your Action to make a successful Challenging (+0) Athletics Test."
        ),
        Condition(
            name: "Ablaze (Major)",
            description: "You suffer 1d10 Damage at the start of your turn, which ignores armour. White you are Ablaze, you automatically fail all Stealth Tests. Unless specified otherwise, you may remove an Ablaze condition by dropping Prone and using your Action to make a successful Challenging (+0) Athletics Test."
        ),
        Condition(
            name: "Bleeding (Minor)",
            description: "You suffer 1 Damage at the end of your turn, which ignores Armour. If you exceed your Wound Maximum because of the Bleeding Condition, you suffer a Critical Wound as normal. Once this has occurred, you no longer suffer any damage due to Bleeding, but can't recover Wounds until the Bleeding has been treated."
        ),
        Condition(
            name: "Bleeding (Major)",
            description: "You suffer 3 Damage at the end of your turn, which ignores Armour. If you exceed your Wound Maximum because of the Bleeding Condition, you suffer a Critical Wound as normal. Once this has occurred, you no longer suffer any damage due to Bleeding, but can't recover Wounds until the Bleeding has been treated."
        ),
        Condition(
            name: "Blinded",
            description: "You can only succeed on Tests that rely on sight, such as Awareness (Sight) and Ranged Tests, by rolling a 01–05. You have Disadvantage on Melee and Dodge (Reflexes) Tests. Unless specified otherwise, a Blinded condition is lost after 1d10 rounds."
        ),
        Condition(
            name: "Deafened",
            description: "You can only succeed on Tests that rely on hearing, such as Awareness (Sound), by rolling a 01–05. Unless specified otherwise, a Deafened condition is lost after 1d10 minutes."
        ),
        Condition(
            name: "Fatigued (Minor)",
            description: "You have Disadvantage on all Tests. Unless specified otherwise, you may remove a Fatigued Condition by undertaking six hours of rest."
        ),
        Condition(
            name: "Fatigued (Major)",
            description: "All Tests you make have their difficultly increased to Very Hard (−30). If you would gain Fatigued again while already under the effects of Fatigued (Major), you may continue to act for a number of minutes equal to your Toughness Bonus, after which you fall Unconscious. Unless specified otherwise, you may remove a Fatigued Condition by undertaking six hours of rest."
        ),
        Condition(
            name: "Frightened (Minor)",
            description: "Due to your fear and heightened senses, you have Advantage on Awareness and Intuition Tests. However, you have Disadvantage on all Tests relating to confronting the source of your fear. Unless specified otherwise, at the end of each round, you may make a Challenging (+0) Discipline (Fear) Test to remove this Condition."
        ),
        Condition(
            name: "Frightened (Major)",
            description: "You are terrified. You must run from the source of your fear in the most direct route possible, stopping only to open doors or otherwise free yourself from your current situation. Unless specified otherwise, at the end of each round, you may make a Challenging (+0) Discipline (Fear) Test to remove this Condition."
        ),
        Condition(
            name: "Incapacitated",
            description: "You can't Move or take Actions. You can't defend yourself. Melee attacks against you automatically score a Critical Hit."
        ),
        Condition(
            name: "Overburdened",
            description: "You have Disadvantage on all Agility Tests and your Speed is reduced one step."
        ),
        Condition(
            name: "Poisoned (Minor)",
            description: "You have Disadvantage on Strength and Toughness Tests. The maximum SL you can achieve on any Test is equal to your Toughness Bonus. If the duration of a Poisoned condition is not specified, it lasts for 1d5 hours."
        ),
        Condition(
            name: "Poisoned (Major)",
            description: "You become Prone and Incapacitated. If the duration of a Poisoned condition is not specified, it lasts for 1d5 hours."
        ),
        Condition(
            name: "Prone",
            description: "You can only move by crawling, unless you use your Move to stand up. You have Disadvantage on Melee Tests. Creatures attacking you from within Immediate Range have Advantage on their attack Test. Creatures attacking you from outside Immediate Range have Disadvantage on their attack Test."
        ),
        Condition(
            name: "Restrained (Minor)",
            description: "You cannot take move Move actions. You have Disadvantage on Tests involving movement of any kind, including Athletics, Dexterity, Melee, Reflexes, and Ranged Tests."
        ),
        Condition(
            name: "Restrained (Major)",
            description: "You become Incapacitated."
        ),
        Condition(
            name: "Stunned (Minor)",
            description: "You can take either a Move or an Action, but not both. If the duration of a Stunned condition is not specified, it lasts for 1d5 rounds."
        ),
        Condition(
            name: "Stunned (Major)",
            description: "You can take either a Move or an Action, but not both. Additionally, you have Disadvantage on all Tests. If the duration of a Stunned condition is not specified, it lasts for 1d5 rounds."
        ),
        Condition(
            name: "Unconscious",
            description: "You immediately drop anything you are holding, fall Prone, and become Incapacitated. Anyone within Immediate Range with a weapon that does not have the Ineffective Trait can kill you without needing to make a Test."
        )
    ]
}