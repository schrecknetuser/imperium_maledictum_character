//
//  FactionModel.swift
//  ImperiumMaledictumCharacter
//
//  Created by User on 11.01.2025.
//

import Foundation

struct TalentChoice {
    var name: String
    var talents: [String]
    
    init(name: String, talents: [String]) {
        self.name = name
        self.talents = talents
    }
}

struct Faction {
    var name: String
    var mandatoryBonus: CharacteristicBonus
    var choiceBonus: [CharacteristicBonus]
    var skillAdvances: [String] // Skills to distribute 5 advances among
    var influenceBonus: String // Faction to gain +1 influence with
    var talents: [String] // Automatically granted talents
    var talentChoices: [TalentChoice] // Choice-based talents (user must select one)
    var equipment: [String] // Granted equipment
    var solars: Int // Starting solars
    var description: String
    
    init(name: String, mandatoryBonus: CharacteristicBonus, choiceBonus: [CharacteristicBonus], skillAdvances: [String], influenceBonus: String, talents: [String] = [], talentChoices: [TalentChoice] = [], equipment: [String], solars: Int, description: String = "") {
        self.name = name
        self.mandatoryBonus = mandatoryBonus
        self.choiceBonus = choiceBonus
        self.skillAdvances = skillAdvances
        self.influenceBonus = influenceBonus
        self.talents = talents
        self.talentChoices = talentChoices
        self.equipment = equipment
        self.solars = solars
        self.description = description
    }
}

struct Role {
    var name: String
    var talentChoices: [String] // Talents to choose from
    var talentCount: Int // Number of talents to choose
    var skillAdvances: [String] // Skills to distribute advances among
    var skillAdvanceCount: Int // Number of skill advances
    var specializationAdvances: [String] // Specializations to distribute advances among
    var specializationAdvanceCount: Int // Number of specialization advances
    var weaponChoices: [[String]] // Arrays of weapon choices
    var equipment: [String] // Granted equipment
    var equipmentChoices: [[String]] // Arrays of equipment choices
    var description: String
    
    init(name: String, talentChoices: [String], talentCount: Int, skillAdvances: [String], skillAdvanceCount: Int, specializationAdvances: [String], specializationAdvanceCount: Int, weaponChoices: [[String]], equipment: [String], equipmentChoices: [[String]], description: String = "") {
        self.name = name
        self.talentChoices = talentChoices
        self.talentCount = talentCount
        self.skillAdvances = skillAdvances
        self.skillAdvanceCount = skillAdvanceCount
        self.specializationAdvances = specializationAdvances
        self.specializationAdvanceCount = specializationAdvanceCount
        self.weaponChoices = weaponChoices
        self.equipment = equipment
        self.equipmentChoices = equipmentChoices
        self.description = description
    }
}

// MARK: - Faction Definitions
struct FactionDefinitions {
    static let allFactions: [Faction] = [
        Faction(
            name: "Adeptus Astra Telepathica",
            mandatoryBonus: CharacteristicBonus(CharacteristicNames.willpower, 5),
            choiceBonus: [
                CharacteristicBonus(CharacteristicNames.intelligence, 5),
                CharacteristicBonus(CharacteristicNames.perception, 5),
                CharacteristicBonus(CharacteristicNames.toughness, 5)
            ],
            skillAdvances: ["Awareness", "Discipline", "Intuition", "Linguistics", "Psychic Mastery"],
            influenceBonus: "Adeptus Astra Telepathica",
            talents: [],
            talentChoices: [
                TalentChoice(name: "Sanctioned Psyker", talents: ["Psyker", "Sanctioned Psyker"]),
                TalentChoice(name: "Blank", talents: ["Blank"]),
                TalentChoice(name: "Witch Hunter", talents: ["Condemn The Witch", "Mental Fortress"])
            ],
            equipment: ["Knife (Mono-Edge)", "Robes", "Instrument of Divination"],
            solars: 500,
            description: "The organization responsible for training and regulating psykers"
        ),
        Faction(
            name: "Adeptus Mechanicus",
            mandatoryBonus: CharacteristicBonus(CharacteristicNames.intelligence, 5),
            choiceBonus: [
                CharacteristicBonus(CharacteristicNames.toughness, 5),
                CharacteristicBonus(CharacteristicNames.agility, 5),
                CharacteristicBonus(CharacteristicNames.perception, 5)
            ],
            skillAdvances: ["Dexterity", "Logic", "Lore", "Medicae", "Piloting", "Tech"],
            influenceBonus: "Adeptus Mechanicus",
            talents: [],
            equipment: ["Robes", "Dataslate", "Sacred Unguents", "Augur Array"], // Plus augmetic choices
            solars: 100,
            description: "The technological priesthood of Mars"
        ),
        Faction(
            name: "Adeptus Administratum",
            mandatoryBonus: CharacteristicBonus(CharacteristicNames.intelligence, 5),
            choiceBonus: [
                CharacteristicBonus(CharacteristicNames.perception, 5),
                CharacteristicBonus(CharacteristicNames.willpower, 5),
                CharacteristicBonus(CharacteristicNames.fellowship, 5)
            ],
            skillAdvances: ["Dexterity", "Linguistics", "Logic", "Lore", "Medicae", "Navigation"],
            influenceBonus: "Adeptus Administratum",
            talents: ["Data Delver"],
            equipment: ["Robes", "Dataslate", "Writing Kit", "Auto Quill"],
            solars: 800,
            description: "The vast bureaucracy that administers the Imperium"
        ),
        Faction(
            name: "Astra Militarum",
            mandatoryBonus: CharacteristicBonus(CharacteristicNames.toughness, 5),
            choiceBonus: [
                CharacteristicBonus(CharacteristicNames.weaponSkill, 5),
                CharacteristicBonus(CharacteristicNames.ballisticSkill, 5),
                CharacteristicBonus(CharacteristicNames.strength, 5)
            ],
            skillAdvances: ["Athletics", "Discipline", "Fortitude", "Melee", "Ranged", "Stealth"],
            influenceBonus: "Astra Militarum",
            talents: ["Drilled"],
            equipment: ["Knife", "Flak Armour", "Frag Grenade", "Writing Kit", "Lasgun"],
            solars: 300,
            description: "The Imperial Guard - backbone of the Imperial military"
        ),
        Faction(
            name: "Adeptus Ministorum",
            mandatoryBonus: CharacteristicBonus(CharacteristicNames.willpower, 5),
            choiceBonus: [
                CharacteristicBonus(CharacteristicNames.intelligence, 5),
                CharacteristicBonus(CharacteristicNames.perception, 5),
                CharacteristicBonus(CharacteristicNames.fellowship, 5)
            ],
            skillAdvances: ["Discipline", "Intuition", "Lore", "Medicae", "Presence", "Rapport"],
            influenceBonus: "Adeptus Ministorum",
            talents: ["Faithful"],
            equipment: ["Robes", "Holy Icon", "Slings", "Carapace Chestplate"],
            solars: 600,
            description: "The Imperial Church - spiritual guidance for humanity"
        ),
        Faction(
            name: "Inquisition",
            mandatoryBonus: CharacteristicBonus(CharacteristicNames.perception, 5),
            choiceBonus: [
                CharacteristicBonus(CharacteristicNames.toughness, 5),
                CharacteristicBonus(CharacteristicNames.intelligence, 5),
                CharacteristicBonus(CharacteristicNames.willpower, 5)
            ],
            skillAdvances: ["Awareness", "Discipline", "Intuition", "Logic", "Lore", "Presence"],
            influenceBonus: "Inquisition",
            talents: [],
            equipment: ["Laspistol", "Armoured Bodyglove", "Glow-globe", "Manacles", "Auspex"],
            solars: 400,
            description: "The Emperor's secret police and investigators of heresy"
        ),
        Faction(
            name: "Navis Imperialis",
            mandatoryBonus: CharacteristicBonus(CharacteristicNames.agility, 5),
            choiceBonus: [
                CharacteristicBonus(CharacteristicNames.strength, 5),
                CharacteristicBonus(CharacteristicNames.toughness, 5),
                CharacteristicBonus(CharacteristicNames.perception, 5)
            ],
            skillAdvances: ["Awareness", "Logic", "Navigation", "Piloting", "Reflexes", "Tech"],
            influenceBonus: "Navis Imperialis",
            talents: ["Void Legs"],
            equipment: ["Laspistol", "Void Suit", "Lascutter"],
            solars: 500,
            description: "The Imperial Navy - rulers of the void between stars"
        ),
        Faction(
            name: "Rogue Trader Dynasties",
            mandatoryBonus: CharacteristicBonus(CharacteristicNames.fellowship, 5),
            choiceBonus: [
                CharacteristicBonus(CharacteristicNames.agility, 5),
                CharacteristicBonus(CharacteristicNames.intelligence, 5),
                CharacteristicBonus(CharacteristicNames.perception, 5)
            ],
            skillAdvances: ["Intuition", "Linguistics", "Navigation", "Presence", "Piloting", "Rapport"],
            influenceBonus: "Rogue Trader Dynasties",
            talents: ["Dealmaker"],
            equipment: ["Armoured Bodyglove", "Multicompass"],
            solars: 1200,
            description: "Independent merchant princes with licenses to trade beyond Imperial borders"
        ),
        Faction(
            name: "Infractionists",
            mandatoryBonus: CharacteristicBonus(CharacteristicNames.agility, 5),
            choiceBonus: [
                CharacteristicBonus(CharacteristicNames.toughness, 5),
                CharacteristicBonus(CharacteristicNames.perception, 5),
                CharacteristicBonus(CharacteristicNames.fellowship, 5)
            ],
            skillAdvances: ["Athletics", "Dexterity", "Fortitude", "Rapport", "Reflexes", "Stealth"],
            influenceBonus: "Infractionists",
            talents: ["Well-prepared"],
            equipment: ["Knife", "Backpack", "Stub Automatic", "Light Leathers"],
            solars: 50,
            description: "Criminals, smugglers, and those who operate outside Imperial law"
        )
    ]
    
    static func getFaction(by name: String) -> Faction? {
        return allFactions.first { $0.name == name }
    }
}

// MARK: - Role Definitions
struct RoleDefinitions {
    static let allRoles: [Role] = [
        Role(
            name: "Interlocuter",
            talentChoices: ["Air of Authority", "Briber", "Gothic Gibberish", "Dealmaker", "Distracting", "Gallows Humour", "Lickspittle", "Overseer"],
            talentCount: 4,
            skillAdvances: ["Awareness", "Discipline", "Intuition", "Linguistics", "Presence", "Rapport"],
            skillAdvanceCount: 3,
            specializationAdvances: ["Intuition", "Presence", "Rapport"],
            specializationAdvanceCount: 2,
            weaponChoices: [["Knife", "Laspistol", "Stub Revolver"]],
            equipment: ["Survival Gear", "Vox Bead"],
            equipmentChoices: [["Laud Hailer", "Pict Recorder", "Vox-caster"]],
            description: "Masters of communication and negotiation"
        ),
        Role(
            name: "Mystic",
            talentChoices: ["Condemn The Witch", "Fated", "Forbidden Knowledge", "Mental Fortress", "Psyker", "Sanctioned Psyker"],
            talentCount: 2,
            skillAdvances: ["Awareness", "Discipline", "Intuition", "Lore", "Navigation", "Psychic Mastery"],
            skillAdvanceCount: 3,
            specializationAdvances: ["Fear (Discipline)", "Forbidden (Linguistics)", "Forbidden (Lore)", "Psyniscience (Awareness)", "Any (Psychic Mastery)"],
            specializationAdvanceCount: 2,
            weaponChoices: [["Knife", "Staff"], ["Laspistol", "Stub Revolver"]],
            equipment: ["Survival Gear", "Vox Bead"],
            equipmentChoices: [["Psy Focus", "Auspex"]],
            description: "Those touched by the warp or trained to combat it"
        ),
        Role(
            name: "Savant",
            talentChoices: ["Artistic", "Attentive Assistant", "Chirurgeon", "Data Delver", "Eidetic Memory", "Lawbringer"],
            talentCount: 2,
            skillAdvances: ["Logic", "Lore", "Medicae", "Navigation", "Piloting", "Tech"],
            skillAdvanceCount: 3,
            specializationAdvances: ["Lore", "Medicae", "Tech"],
            specializationAdvanceCount: 2,
            weaponChoices: [],
            equipment: ["Survival Gear", "Vox Bead", "Slings", "Dataslate"],
            equipmentChoices: [["Auspex", "Auto-quill"], ["Chirurgeon's Tools", "Combi-Tool", "Diagnostor", "Multicompass", "Multikey"]],
            description: "Scholars, medics, and technical specialists"
        ),
        Role(
            name: "Penumbra",
            talentChoices: ["Burglar", "Familiar Terrain", "Read Lips", "Secret Identity", "Skulker", "Unremarkable"],
            talentCount: 2,
            skillAdvances: ["Athletics", "Awareness", "Dexterity", "Ranged", "Reflexes", "Stealth"],
            skillAdvanceCount: 3,
            specializationAdvances: ["Ranged", "Reflexes", "Stealth"],
            specializationAdvanceCount: 2,
            weaponChoices: [["Autopistol", "Laspistol"], ["Lasgun", "Sniper Rifle"]],
            equipment: ["Survival Gear", "Vox Bead", "Silencer", "Smoke Grenade", "Knife", "Knife"],
            equipmentChoices: [["Auspex", "Comm Leech"], ["Disguise Kit", "Drop Harness", "Grapnel & Line", "Magnoculars", "Multikey", "Pict Recorder", "Photo-visors", "Signal Jammer"]],
            description: "Infiltrators, assassins, and covert operatives"
        ),
        Role(
            name: "Warrior",
            talentChoices: ["Deadeye", "Disarm", "Drilled", "Duellist", "Tactical Movement", "Two-handed Cleave"],
            talentCount: 2,
            skillAdvances: ["Athletics", "Fortitude", "Medicae", "Melee", "Ranged", "Reflexes"],
            skillAdvanceCount: 3,
            specializationAdvances: ["Melee", "Ranged", "Reflexes"],
            specializationAdvanceCount: 2,
            weaponChoices: [["Sword", "Chainsword"], ["Laspistol", "Stub Revolver"], ["Lasgun", "Shotgun (Combat)"]],
            equipment: ["Survival Gear", "Vox Bead", "Frag Grenade", "Backpack", "Knife"],
            equipmentChoices: [["Scrap-plate", "Flak Jacket"]],
            description: "Professional soldiers and combat specialists"
        ),
        Role(
            name: "Zealot",
            talentChoices: ["Faithful", "Flagellant", "Frenzy", "Hatred", "Icon Bearer", "Martyrdom"],
            talentCount: 2,
            skillAdvances: ["Discipline", "Fortitude", "Linguistics", "Lore", "Melee", "Presence"],
            skillAdvanceCount: 3,
            specializationAdvances: ["Discipline", "Lore", "Melee"],
            specializationAdvanceCount: 2,
            weaponChoices: [["Great Weapon", "Chainsword"], ["Laspistol", "Hand Flamer"]],
            equipment: ["Holy Icon", "Vox Bead", "Knife"],
            equipmentChoices: [["Heavy Leathers", "Robe"], ["Heavy Laud Hailer", "Writing Kit"]],
            description: "Fanatical believers driven by unwavering faith"
        )
    ]
    
    static func getRole(by name: String) -> Role? {
        return allRoles.first { $0.name == name }
    }
}