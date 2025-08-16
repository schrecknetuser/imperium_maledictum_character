//
//  OriginModel.swift
//  ImperiumMaledictumCharacter
//
//  Created by User on 11.01.2025.
//

import Foundation

struct Origin {
    var name: String
    var mandatoryBonus: CharacteristicBonus
    var choiceBonus: [CharacteristicBonus]
    var grantedEquipment: [String]
    var description: String
    
    init(name: String, mandatoryBonus: CharacteristicBonus, choiceBonus: [CharacteristicBonus], grantedEquipment: [String], description: String = "") {
        self.name = name
        self.mandatoryBonus = mandatoryBonus
        self.choiceBonus = choiceBonus
        self.grantedEquipment = grantedEquipment
        self.description = description
    }
}

struct CharacteristicBonus {
    var characteristic: String
    var bonus: Int
    
    init(_ characteristic: String, _ bonus: Int) {
        self.characteristic = characteristic
        self.bonus = bonus
    }
}

// MARK: - Origin Definitions
struct OriginDefinitions {
    static let allOrigins: [Origin] = [
        Origin(
            name: "Agri World",
            mandatoryBonus: CharacteristicBonus(CharacteristicNames.strength, 5),
            choiceBonus: [
                CharacteristicBonus(CharacteristicNames.toughness, 5),
                CharacteristicBonus(CharacteristicNames.agility, 5),
                CharacteristicBonus(CharacteristicNames.willpower, 5)
            ],
            grantedEquipment: ["Entrenching Tool (Shoddy)"],
            description: "Rural agricultural worlds where food is produced for the Imperium"
        ),
        Origin(
            name: "Feudal World",
            mandatoryBonus: CharacteristicBonus(CharacteristicNames.weaponSkill, 5),
            choiceBonus: [
                CharacteristicBonus(CharacteristicNames.strength, 5),
                CharacteristicBonus(CharacteristicNames.willpower, 5),
                CharacteristicBonus(CharacteristicNames.fellowship, 5)
            ],
            grantedEquipment: ["Writing Kit (Shoddy)"],
            description: "Medieval-level worlds with feudal societies and limited technology"
        ),
        Origin(
            name: "Feral World",
            mandatoryBonus: CharacteristicBonus(CharacteristicNames.toughness, 5),
            choiceBonus: [
                CharacteristicBonus(CharacteristicNames.weaponSkill, 5),
                CharacteristicBonus(CharacteristicNames.strength, 5),
                CharacteristicBonus(CharacteristicNames.perception, 5)
            ],
            grantedEquipment: ["Survival Gear (Shoddy)"],
            description: "Primitive worlds where humans have reverted to savage tribalism"
        ),
        Origin(
            name: "Forge World",
            mandatoryBonus: CharacteristicBonus(CharacteristicNames.intelligence, 5),
            choiceBonus: [
                CharacteristicBonus(CharacteristicNames.ballisticSkill, 5),
                CharacteristicBonus(CharacteristicNames.toughness, 5),
                CharacteristicBonus(CharacteristicNames.agility, 5)
            ],
            grantedEquipment: ["Sacred Unguents"],
            description: "Industrial worlds dedicated to manufacturing and technology"
        ),
        Origin(
            name: "Hive World",
            mandatoryBonus: CharacteristicBonus(CharacteristicNames.agility, 5),
            choiceBonus: [
                CharacteristicBonus(CharacteristicNames.ballisticSkill, 5),
                CharacteristicBonus(CharacteristicNames.perception, 5),
                CharacteristicBonus(CharacteristicNames.fellowship, 5)
            ],
            grantedEquipment: ["Filtration Plugs (Ugly)"],
            description: "Massive city-worlds with billions of inhabitants in towering hives"
        ),
        Origin(
            name: "Shrine World",
            mandatoryBonus: CharacteristicBonus(CharacteristicNames.willpower, 5),
            choiceBonus: [
                CharacteristicBonus(CharacteristicNames.intelligence, 5),
                CharacteristicBonus(CharacteristicNames.perception, 5),
                CharacteristicBonus(CharacteristicNames.fellowship, 5)
            ],
            grantedEquipment: ["Holy Icon"],
            description: "Worlds dedicated to the worship of the God-Emperor"
        ),
        Origin(
            name: "Schola Progenium",
            mandatoryBonus: CharacteristicBonus(CharacteristicNames.fellowship, 5),
            choiceBonus: [
                CharacteristicBonus(CharacteristicNames.weaponSkill, 5),
                CharacteristicBonus(CharacteristicNames.ballisticSkill, 5),
                CharacteristicBonus(CharacteristicNames.toughness, 5)
            ],
            grantedEquipment: ["Chrono"],
            description: "Imperial orphanages that train children for service to the Imperium"
        ),
        Origin(
            name: "Voidborn",
            mandatoryBonus: CharacteristicBonus(CharacteristicNames.perception, 5),
            choiceBonus: [
                CharacteristicBonus(CharacteristicNames.agility, 5),
                CharacteristicBonus(CharacteristicNames.intelligence, 5),
                CharacteristicBonus(CharacteristicNames.willpower, 5)
            ],
            grantedEquipment: ["Chrono"],
            description: "Those born and raised aboard starships and space stations"
        )
    ]
    
    static func getOrigin(by name: String) -> Origin? {
        return allOrigins.first { $0.name == name }
    }
}