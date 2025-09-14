//
//  ArmorModel.swift
//  ImperiumMaledictumCharacter
//
//  Created by User on 11.01.2025.
//

import Foundation

class Armor: Codable {
    var id: UUID
    var name: String
    var armorDescription: String
    var category: String // Basic, Flak, Mesh, Carapace, Power
    var locations: [String] // Arms, Body, Legs, Head, All, Special
    var armorValue: Int // Armor points provided
    var encumbrance: Int
    var cost: Int
    var availability: String
    var qualitiesData: String // JSON array of strings
    var flawsData: String // JSON array of strings
    var traitsData: String // JSON array of ArmorTrait
    
    // For backward compatibility with Armor objects that don't have IDs
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Try to decode ID, if it doesn't exist, generate a new one
        if let decodedId = try? container.decode(UUID.self, forKey: .id) {
            self.id = decodedId
        } else {
            self.id = UUID()
        }
        
        self.name = try container.decode(String.self, forKey: .name)
        self.armorDescription = try container.decode(String.self, forKey: .armorDescription)
        self.category = try container.decode(String.self, forKey: .category)
        self.locations = try container.decode([String].self, forKey: .locations)
        self.armorValue = try container.decode(Int.self, forKey: .armorValue)
        self.encumbrance = try container.decode(Int.self, forKey: .encumbrance)
        self.cost = try container.decode(Int.self, forKey: .cost)
        self.availability = try container.decode(String.self, forKey: .availability)
        self.qualitiesData = try container.decode(String.self, forKey: .qualitiesData)
        self.flawsData = try container.decode(String.self, forKey: .flawsData)
        self.traitsData = try container.decode(String.self, forKey: .traitsData)
    }
    
    enum CodingKeys: String, CodingKey {
        case id, name, armorDescription, category, locations, armorValue, encumbrance, cost, availability, qualitiesData, flawsData, traitsData
    }
    
    var qualities: [String] {
        get {
            guard let data = qualitiesData.data(using: .utf8),
                  let decoded = try? JSONDecoder().decode([String].self, from: data) else {
                return []
            }
            return decoded
        }
        set {
            if let encoded = try? JSONEncoder().encode(newValue) {
                qualitiesData = String(data: encoded, encoding: .utf8) ?? ""
            }
        }
    }
    
    var flaws: [String] {
        get {
            guard let data = flawsData.data(using: .utf8),
                  let decoded = try? JSONDecoder().decode([String].self, from: data) else {
                return []
            }
            return decoded
        }
        set {
            if let encoded = try? JSONEncoder().encode(newValue) {
                flawsData = String(data: encoded, encoding: .utf8) ?? ""
            }
        }
    }
    
    var traits: [ArmorTrait] {
        get {
            guard let data = traitsData.data(using: .utf8),
                  let decoded = try? JSONDecoder().decode([ArmorTrait].self, from: data) else {
                return []
            }
            return decoded
        }
        set {
            if let encoded = try? JSONEncoder().encode(newValue) {
                traitsData = String(data: encoded, encoding: .utf8) ?? ""
            }
        }
    }
    
    init(name: String, armorDescription: String = "", category: String = ArmorCategories.basic, locations: [String] = [], armorValue: Int = 0, encumbrance: Int = 0, cost: Int = 0, availability: String = "Common") {
        self.id = UUID()
        self.name = name
        self.armorDescription = armorDescription
        self.category = category
        self.locations = locations
        self.armorValue = armorValue
        self.encumbrance = encumbrance
        self.cost = cost
        self.availability = availability
        self.qualitiesData = ""
        self.flawsData = ""
        self.traitsData = ""
    }
}

struct ArmorTrait: Codable {
    var name: String
    var traitDescription: String
    var parameter: String
    
    var displayName: String {
        return parameter.isEmpty ? name : "\(name) (\(parameter))"
    }
    
    init(name: String, traitDescription: String = "", parameter: String = "") {
        self.name = name
        self.traitDescription = traitDescription
        self.parameter = parameter
    }
}

// MARK: - Armor Constants
struct ArmorCategories {
    static let basic = "Basic"
    static let flak = "Flak"
    static let mesh = "Mesh"
    static let carapace = "Carapace"
    static let power = "Power"
    
    static let all = [basic, flak, mesh, carapace, power]
}

struct ArmorLocations {
    static let head = "Head"
    static let arms = "Arms"
    static let body = "Body"
    static let legs = "Legs"
    static let all = "All"
    static let special = "Special"
    
    static let allLocations = [head, arms, body, legs, all, special]
}

struct ArmorTraitNames {
    static let heavy = "Heavy"
    static let loud = "Loud"
    static let shield = "Shield"
    static let subtle = "Subtle"
    
    static let all = [heavy, loud, shield, subtle]
}

// MARK: - Armor Template System
struct ArmorTemplate {
    var name: String
    var category: String
    var description: String
    var locations: [String]
    var armorValue: Int
    var encumbrance: Int
    var cost: Int
    var availability: String
    var qualities: [String]
    var flaws: [String]
    var traits: [ArmorTrait]
    
    init(name: String, category: String, description: String = "", locations: [String] = [], armorValue: Int = 0, encumbrance: Int = 0, cost: Int = 0, availability: String = "Common", qualities: [String] = [], flaws: [String] = [], traits: [ArmorTrait] = []) {
        self.name = name
        self.category = category
        self.description = description
        self.locations = locations
        self.armorValue = armorValue
        self.encumbrance = encumbrance
        self.cost = cost
        self.availability = availability
        self.qualities = qualities
        self.flaws = flaws
        self.traits = traits
    }
    
    func createArmor() -> Armor {
        let armor = Armor(
            name: name,
            armorDescription: description,
            category: category,
            locations: locations,
            armorValue: armorValue,
            encumbrance: encumbrance,
            cost: cost,
            availability: availability
        )
        armor.qualities = qualities
        armor.flaws = flaws
        armor.traits = traits
        return armor
    }
}

struct ArmorTemplateDefinitions {
    // MARK: - Basic Armor
    static let basicArmor: [ArmorTemplate] = [
        ArmorTemplate(
            name: "Robes",
            category: ArmorCategories.basic,
            description: "Basic protective clothing.",
            locations: [ArmorLocations.arms, ArmorLocations.body, ArmorLocations.legs],
            armorValue: 1,
            encumbrance: 1,
            cost: 10,
            availability: AvailabilityLevels.common,
            traits: [ArmorTrait(name: ArmorTraitNames.subtle)]
        ),
        ArmorTemplate(
            name: "Light Leathers",
            category: ArmorCategories.basic,
            description: "Basic light leather garments.",
            locations: [ArmorLocations.arms, ArmorLocations.body, ArmorLocations.legs],
            armorValue: 1,
            encumbrance: 1,
            cost: 10,
            availability: AvailabilityLevels.common,
            traits: [ArmorTrait(name: ArmorTraitNames.subtle)]
        ),
        ArmorTemplate(
            name: "Heavy Leathers",
            category: ArmorCategories.basic,
            description: "Thick, durable leather armor providing basic protection.",
            locations: [ArmorLocations.arms, ArmorLocations.body, ArmorLocations.legs],
            armorValue: 2,
            encumbrance: 1,
            cost: 60,
            availability: AvailabilityLevels.common
        ),
        ArmorTemplate(
            name: "Armoured Bodyglove",
            category: ArmorCategories.basic,
            description: "A form-fitting suit with protective elements woven throughout.",
            locations: [ArmorLocations.arms, ArmorLocations.body, ArmorLocations.legs],
            armorValue: 2,
            encumbrance: 1,
            cost: 1200,
            availability: AvailabilityLevels.rare,
            traits: [ArmorTrait(name: ArmorTraitNames.subtle)]
        ),
        ArmorTemplate(
            name: "Armoured Greatcoat",
            category: ArmorCategories.basic,
            description: "A long coat with armor plates sewn into the lining.",
            locations: [ArmorLocations.arms, ArmorLocations.body, ArmorLocations.legs],
            armorValue: 2,
            encumbrance: 2,
            cost: 500,
            availability: AvailabilityLevels.rare,
            traits: [ArmorTrait(name: ArmorTraitNames.subtle)]
        ),
        ArmorTemplate(
            name: "Scrap-plate",
            category: ArmorCategories.basic,
            description: "Improvised armor made from salvaged metal plates.",
            locations: [ArmorLocations.body],
            armorValue: 3,
            encumbrance: 2,
            cost: 300,
            availability: AvailabilityLevels.rare,
            traits: [ArmorTrait(name: ArmorTraitNames.heavy, parameter: "3")]
        ),
        ArmorTemplate(
            name: "Combat Shield",
            category: ArmorCategories.basic,
            description: "A portable defensive shield for close combat.",
            locations: [ArmorLocations.special],
            armorValue: 0,
            encumbrance: 2,
            cost: 700,
            availability: AvailabilityLevels.common,
            traits: [ArmorTrait(name: ArmorTraitNames.shield, parameter: "2")]
        ),
        ArmorTemplate(
            name: "Boarding Shield",
            category: ArmorCategories.basic,
            description: "A large, reinforced shield used in ship-to-ship combat.",
            locations: [ArmorLocations.special],
            armorValue: 0,
            encumbrance: 4,
            cost: 1400,
            availability: AvailabilityLevels.rare,
            traits: [ArmorTrait(name: ArmorTraitNames.shield, parameter: "4")]
        ),
        ArmorTemplate(
            name: "Xenos Hide Vest",
            category: ArmorCategories.basic,
            description: "Armor crafted from the hide of dangerous xenos creatures.",
            locations: [ArmorLocations.body],
            armorValue: 6,
            encumbrance: 1,
            cost: 5000,
            availability: AvailabilityLevels.exotic
        )
    ]
    
    // MARK: - Flak Armor
    static let flakArmor: [ArmorTemplate] = [
        ArmorTemplate(
            name: "Flak Boots",
            category: ArmorCategories.flak,
            description: "Reinforced boots with flak armor plating.",
            locations: [ArmorLocations.legs],
            armorValue: 2,
            encumbrance: 2,
            cost: 100,
            availability: AvailabilityLevels.common
        ),
        ArmorTemplate(
            name: "Flak Helmet",
            category: ArmorCategories.flak,
            description: "A protective helmet with flak armor plating.",
            locations: [ArmorLocations.head],
            armorValue: 2,
            encumbrance: 2,
            cost: 150,
            availability: AvailabilityLevels.common
        ),
        ArmorTemplate(
            name: "Flak Gauntlets (pair)",
            category: ArmorCategories.flak,
            description: "Protective gloves with flak armor reinforcement.",
            locations: [ArmorLocations.arms],
            armorValue: 2,
            encumbrance: 1,
            cost: 100,
            availability: AvailabilityLevels.common
        ),
        ArmorTemplate(
            name: "Flak Vest",
            category: ArmorCategories.flak,
            description: "A basic flak armor vest protecting the torso.",
            locations: [ArmorLocations.body],
            armorValue: 2,
            encumbrance: 2,
            cost: 500,
            availability: AvailabilityLevels.common
        ),
        ArmorTemplate(
            name: "Flak Jacket",
            category: ArmorCategories.flak,
            description: "Extended flak armor covering arms and torso.",
            locations: [ArmorLocations.arms, ArmorLocations.body],
            armorValue: 3,
            encumbrance: 2,
            cost: 800,
            availability: AvailabilityLevels.scarce
        ),
        ArmorTemplate(
            name: "Astra Militarum Flak Armour",
            category: ArmorCategories.flak,
            description: "Standard issue Imperial Guard flak armor providing full body protection.",
            locations: [ArmorLocations.all],
            armorValue: 4,
            encumbrance: 4,
            cost: 1000,
            availability: AvailabilityLevels.rare,
            traits: [ArmorTrait(name: ArmorTraitNames.loud)]
        ),
        // Alias for backward compatibility
        ArmorTemplate(
            name: "Flak Armour",
            category: ArmorCategories.flak,
            description: "Standard issue Imperial Guard flak armor providing full body protection.",
            locations: [ArmorLocations.all],
            armorValue: 4,
            encumbrance: 4,
            cost: 1000,
            availability: AvailabilityLevels.rare,
            traits: [ArmorTrait(name: ArmorTraitNames.loud)]
        )
    ]
    
    // MARK: - Mesh Armor
    static let meshArmor: [ArmorTemplate] = [
        ArmorTemplate(
            name: "Mesh Boots",
            category: ArmorCategories.mesh,
            description: "Boots reinforced with mesh armor weaving.",
            locations: [ArmorLocations.legs],
            armorValue: 3,
            encumbrance: 1,
            cost: 600,
            availability: AvailabilityLevels.rare
        ),
        ArmorTemplate(
            name: "Mesh Cowl",
            category: ArmorCategories.mesh,
            description: "A hood with integrated mesh armor protection.",
            locations: [ArmorLocations.head],
            armorValue: 3,
            encumbrance: 1,
            cost: 800,
            availability: AvailabilityLevels.rare
        ),
        ArmorTemplate(
            name: "Mesh Gauntlets",
            category: ArmorCategories.mesh,
            description: "Lightweight gloves with mesh armor protection.",
            locations: [ArmorLocations.arms],
            armorValue: 3,
            encumbrance: 0,
            cost: 600,
            availability: AvailabilityLevels.rare
        ),
        ArmorTemplate(
            name: "Mesh Vest",
            category: ArmorCategories.mesh,
            description: "A lightweight vest with mesh armor weaving.",
            locations: [ArmorLocations.body],
            armorValue: 4,
            encumbrance: 1,
            cost: 500,
            availability: AvailabilityLevels.rare
        ),
        ArmorTemplate(
            name: "Xenos Mesh",
            category: ArmorCategories.mesh,
            description: "Advanced mesh armor crafted from xenos materials.",
            locations: [ArmorLocations.arms, ArmorLocations.body, ArmorLocations.legs],
            armorValue: 4,
            encumbrance: 2,
            cost: 5000,
            availability: AvailabilityLevels.exotic
        )
    ]
    
    // MARK: - Carapace Armor
    static let carapaceArmor: [ArmorTemplate] = [
        ArmorTemplate(
            name: "Carapace Helm",
            category: ArmorCategories.carapace,
            description: "A reinforced helmet with carapace armor plating.",
            locations: [ArmorLocations.head],
            armorValue: 5,
            encumbrance: 2,
            cost: 400,
            availability: AvailabilityLevels.rare
        ),
        ArmorTemplate(
            name: "Carapace Gauntlets",
            category: ArmorCategories.carapace,
            description: "Heavy gauntlets with carapace armor plates.",
            locations: [ArmorLocations.arms],
            armorValue: 5,
            encumbrance: 2,
            cost: 300,
            availability: AvailabilityLevels.rare
        ),
        ArmorTemplate(
            name: "Carapace Greaves",
            category: ArmorCategories.carapace,
            description: "Leg armor with carapace plating.",
            locations: [ArmorLocations.legs],
            armorValue: 5,
            encumbrance: 2,
            cost: 300,
            availability: AvailabilityLevels.rare
        ),
        ArmorTemplate(
            name: "Carapace Chestplate",
            category: ArmorCategories.carapace,
            description: "Heavy torso armor with carapace plating.",
            locations: [ArmorLocations.body],
            armorValue: 6,
            encumbrance: 3,
            cost: 800,
            availability: AvailabilityLevels.rare,
            traits: [
                ArmorTrait(name: ArmorTraitNames.heavy, parameter: "4"),
                ArmorTrait(name: ArmorTraitNames.loud)
            ]
        ),
        ArmorTemplate(
            name: "Enforcer Carapace",
            category: ArmorCategories.carapace,
            description: "Full carapace armor suit used by Imperial enforcers.",
            locations: [ArmorLocations.all],
            armorValue: 5,
            encumbrance: 4,
            cost: 1800,
            availability: AvailabilityLevels.rare,
            traits: [
                ArmorTrait(name: ArmorTraitNames.heavy, parameter: "4"),
                ArmorTrait(name: ArmorTraitNames.loud)
            ]
        ),
        ArmorTemplate(
            name: "Tempestus Carapace",
            category: ArmorCategories.carapace,
            description: "Elite carapace armor used by Tempestus Scions.",
            locations: [ArmorLocations.all],
            armorValue: 6,
            encumbrance: 5,
            cost: 4000,
            availability: AvailabilityLevels.exotic,
            traits: [
                ArmorTrait(name: ArmorTraitNames.heavy, parameter: "4"),
                ArmorTrait(name: ArmorTraitNames.loud)
            ]
        )
    ]
    
    // MARK: - Power Armor
    static let powerArmor: [ArmorTemplate] = [
        ArmorTemplate(
            name: "Light Power Armour",
            category: ArmorCategories.power,
            description: "Lightweight powered armor with enhanced protection.",
            locations: [ArmorLocations.all],
            armorValue: 8,
            encumbrance: 7,
            cost: 500000,
            availability: AvailabilityLevels.exotic,
            traits: [ArmorTrait(name: ArmorTraitNames.loud)]
        ),
        ArmorTemplate(
            name: "Power Armour",
            category: ArmorCategories.power,
            description: "Full powered armor providing maximum protection.",
            locations: [ArmorLocations.all],
            armorValue: 10,
            encumbrance: 9,
            cost: 1000000,
            availability: AvailabilityLevels.exotic,
            traits: [ArmorTrait(name: ArmorTraitNames.loud)]
        )
    ]
    
    static let allArmor: [ArmorTemplate] = basicArmor + flakArmor + meshArmor + carapaceArmor + powerArmor
    
    static func getTemplate(for name: String) -> ArmorTemplate? {
        return allArmor.first { $0.name.lowercased() == name.lowercased() }
    }
    
    static func getArmorByCategory(_ category: String) -> [ArmorTemplate] {
        return allArmor.filter { $0.category == category }
    }
    
    static func getCategoryForArmor(_ armorName: String) -> String {
        if let template = getTemplate(for: armorName) {
            return template.category
        }
        return ArmorCategories.basic
    }
}
