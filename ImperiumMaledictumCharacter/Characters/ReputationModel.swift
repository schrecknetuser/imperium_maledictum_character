//
//  ReputationModel.swift
//  ImperiumMaledictumCharacter
//
//  Created by User on 11.01.2025.
//

import Foundation

struct Reputation: Codable, Identifiable {
    var id: String { "\(faction)-\(individual)" }
    var faction: String
    var individual: String // Empty string if it's general faction reputation
    var value: Int
    
    init(faction: String, individual: String = "", value: Int = 0) {
        self.faction = faction
        self.individual = individual
        self.value = value
    }
    
    var displayName: String {
        return individual.isEmpty ? faction : "\(individual) (\(faction))"
    }
}

// MARK: - Faction Constants
struct ImperiumFactionsList {
    static let factions = [
        "Adeptus Astra Telepathica",
        "Adeptus Mechanicus",
        "Adeptus Administratum",
        "Astra Militarum",
        "Adeptus Ministorum",
        "Inquisition",
        "Navis Imperialis",
        "Rogue Trader Dynasties",
        "Infractionists"
    ]
}