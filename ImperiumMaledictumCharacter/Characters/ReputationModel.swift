//
//  ReputationModel.swift
//  ImperiumMaledictumCharacter
//
//  Created by User on 11.01.2025.
//

import Foundation

struct Reputation: Codable {
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
        "Adeptus Administratum",
        "Adeptus Arbites",
        "Adeptus Astra Telepathica", 
        "Adeptus Mechanicus",
        "Astra Militarum",
        "Ecclesiarchy",
        "Imperial Navy",
        "Inquisition",
        "Rogue Trader Dynasty",
        "Adeptus Astartes",
        "Local Planetary Governor",
        "Merchants Guild",
        "Criminal Organizations",
        "Chaos Cults",
        "Xenos Traders"
    ]
}