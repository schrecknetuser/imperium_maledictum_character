//
//  PsychicPowersTabView.swift
//  ImperiumMaledictumCharacter
//
//  Created by User on 11.01.2025.
//

import SwiftUI

struct PsychicPowersTab: View {
    let character: any BaseCharacter
    @ObservedObject var store: CharacterStore
    @Binding var isEditMode: Bool
    
    var imperiumCharacter: ImperiumCharacter? {
        return character as? ImperiumCharacter
    }
    
    var body: some View {
        NavigationView {
            List {
                if let imperium = imperiumCharacter {
                    ForEach(imperium.psychicPowers, id: \.self) { power in
                        Text(power)
                    }
                } else {
                    Text("Psychic powers not available for this character type")
                        .foregroundColor(.secondary)
                }
            }
            .navigationTitle("Psychic Powers")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}