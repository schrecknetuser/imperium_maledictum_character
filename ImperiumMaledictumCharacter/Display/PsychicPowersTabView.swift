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
    
    var imperiumCharacterBinding: Binding<ImperiumCharacter>? {
        guard character is ImperiumCharacter else { return nil }
        return Binding(
            get: { character as! ImperiumCharacter },
            set: { newValue in
                // This won't modify the original character since it's let, but needed for binding
            }
        )
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
                
                // Invisible spacer for floating buttons
                Section {
                    Color.clear.frame(height: 76)
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                }
            }
            .navigationTitle("Psychic Powers")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}