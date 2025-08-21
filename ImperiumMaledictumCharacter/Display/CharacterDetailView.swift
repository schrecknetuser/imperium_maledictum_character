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
    @State private var editModeSnapshot: CharacterSnapshot?
    @State private var showingUnifiedStatusPopup = false
    @State private var showingChangeHistoryPopup = false
    
    var imperiumCharacter: ImperiumCharacter? {
        return character as? ImperiumCharacter
    }
    
    var imperiumCharacterBinding: Binding<ImperiumCharacter>? {
        guard character is ImperiumCharacter else { return nil }
        return Binding(
            get: { character as! ImperiumCharacter },
            set: { newValue in
                character = newValue
            }
        )
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
            
            PsychicPowersTab(character: character, store: store, isEditMode: $isEditMode)
                .tabItem {
                    Image(systemName: "brain.head.profile")
                    Text("Psychic Powers")
                }
                .tag(5)
        }
        .overlay(alignment: .bottomTrailing) {
            // Floating Action Buttons - positioned at TabView level
            HStack(spacing: 16) {
                // Change History Button
                Button {
                    showingChangeHistoryPopup = true
                } label: {
                    Image(systemName: "clock.arrow.circlepath")
                        .font(.title2)
                        .foregroundColor(.white)
                        .frame(width: 56, height: 56)
                        .background(Color.orange)
                        .clipShape(Circle())
                        .shadow(radius: 4)
                }
                
                // Status Button
                Button {
                    showingUnifiedStatusPopup = true
                } label: {
                    Image(systemName: "heart.text.square")
                        .font(.title2)
                        .foregroundColor(.white)
                        .frame(width: 56, height: 56)
                        .background(Color.blue)
                        .clipShape(Circle())
                        .shadow(radius: 4)
                }
            }
            .padding(.trailing, 20)
            .padding(.bottom, 100) // Increased padding to clear tab bar (49pt) + safe area
        }
        .navigationTitle(character.name.isEmpty ? "Unnamed Character" : character.name)
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                if isEditMode {
                    Button("Done") {
                        // Save all changes with change tracking
                        if let imperium = character as? ImperiumCharacter {
                            if let snapshot = editModeSnapshot {
                                store.saveCharacterWithAutoChangeTracking(imperium, originalSnapshot: snapshot)
                            } else {
                                store.saveChanges()
                            }
                        } else {
                            store.saveChanges()
                        }
                        isEditMode = false
                        editModeSnapshot = nil
                    }
                } else {
                    Button("Edit") {
                        // Capture snapshot when entering edit mode
                        if let imperium = character as? ImperiumCharacter {
                            editModeSnapshot = store.createSnapshot(of: imperium)
                        }
                        isEditMode = true
                    }
                }
            }
        }
        .sheet(isPresented: $showingUnifiedStatusPopup) {
            if let binding = imperiumCharacterBinding {
                UnifiedStatusPopupView(character: binding, store: store)
            }
        }
        .sheet(isPresented: $showingChangeHistoryPopup) {
            if let binding = imperiumCharacterBinding {
                ChangeHistoryPopupView(character: binding, store: store)
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
