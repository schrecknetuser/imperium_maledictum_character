//
//  CharacterDetailView.swift
//  ImperiumMaledictumCharacter
//
//  Created by User on 11.01.2025.
//

import SwiftUI

struct CharacterDetailView: View {
    @Binding var character: any BaseCharacter
    @ObservedObject var store: CharacterStore
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedTab: Int = 0
    @State private var isEditMode = false
    
    var imperiumCharacter: ImperiumCharacter? {
        return character as? ImperiumCharacter
    }
    
    var body: some View {
        TabView(selection: $selectedTab) {
            OverviewTab(character: $character, store: store, isEditMode: $isEditMode)
                .tabItem {
                    Image(systemName: "person.circle")
                    Text("Overview")
                }
                .tag(0)
            
            CharacteristicsTab(character: character, store: store, isEditMode: $isEditMode)
                .tabItem {
                    Image(systemName: "chart.bar")
                    Text("Stats")
                }
                .tag(1)
            
            ReputationTab(character: character, store: store, isEditMode: $isEditMode)
                .tabItem {
                    Image(systemName: "person.2.circle")
                    Text("Reputation")
                }
                .tag(2)
            
            TalentsTab(character: character, store: store, isEditMode: $isEditMode)
                .tabItem {
                    Image(systemName: "star.circle")
                    Text("Talents")
                }
                .tag(3)
            
            EquipmentTab(character: character, store: store, isEditMode: $isEditMode)
                .tabItem {
                    Image(systemName: "bag")
                    Text("Equipment")
                }
                .tag(4)
            
            if imperiumCharacter?.role.lowercased().contains("psyker") == true {
                PsychicPowersTab(character: character, store: store, isEditMode: $isEditMode)
                    .tabItem {
                        Image(systemName: "brain")
                        Text("Psychic")
                    }
                    .tag(5)
            }
        }
        .navigationTitle(character.name.isEmpty ? "Unnamed Character" : character.name)
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                if isEditMode {
                    Button("Done") {
                        // Save all changes
                        if let imperium = character as? ImperiumCharacter {
                            imperium.lastModified = Date()
                        }
                        store.saveChanges()
                        isEditMode = false
                    }
                } else {
                    Button("Edit") {
                        isEditMode = true
                    }
                }
            }
        }
    }
}

#Preview {
    let character = ImperiumCharacter()
    character.name = "Inquisitor Vex"
    character.faction = "Inquisition"
    character.role = "Acolyte"
    character.homeworld = "Hive World"
    character.maxWounds = 15
    character.wounds = 12
    character.corruption = 5
    
    let binding = Binding<any BaseCharacter>(
        get: { character },
        set: { _ in }
    )
    
    return NavigationStack {
        CharacterDetailView(character: binding, store: CharacterStore())
    }
}
