//
//  TalentsTabView.swift
//  ImperiumMaledictumCharacter
//
//  Created by User on 11.01.2025.
//

import SwiftUI

struct TalentsTab: View {
    let character: any BaseCharacter
    @ObservedObject var store: CharacterStore
    @Binding var isEditMode: Bool
    @State private var showingAddTalentSheet = false
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
                // This won't modify the original character since it's let, but needed for binding
            }
        )
    }
    
    var body: some View {
        NavigationView {
            List {
                if let imperium = imperiumCharacter {
                    ForEach(imperium.talentNames, id: \.self) { talent in
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(talent)
                                    .font(.body)
                                
                                if let description = TalentDefinitions.talents[talent] {
                                    Text(description)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                        .multilineTextAlignment(.leading)
                                }
                            }
                            
                            Spacer()
                            
                            if isEditMode {
                                Button(action: {
                                    removeTalent(talent)
                                }) {
                                    Image(systemName: "minus.circle.fill")
                                        .foregroundColor(.red)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding(.vertical, 2)
                    }
                    
                    if isEditMode {
                        Button(action: {
                            showingAddTalentSheet = true
                        }) {
                            HStack {
                                Image(systemName: "plus.circle.fill")
                                    .foregroundColor(.blue)
                                Text("Add Talent")
                                    .foregroundColor(.blue)
                                Spacer()
                            }
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    
                    if imperium.talentNames.isEmpty && !isEditMode {
                        Text("No talents selected")
                            .foregroundColor(.secondary)
                            .italic()
                    }
                } else {
                    Text("Talents not available for this character type")
                        .foregroundColor(.secondary)
                }
            }
            .navigationTitle("Talents")
            .navigationBarTitleDisplayMode(.inline)
        }
        .overlay(alignment: .bottomTrailing) {
            // Floating Action Buttons
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
            .padding(.bottom, 20)
        }
        .sheet(isPresented: $showingAddTalentSheet) {
            if let imperium = imperiumCharacter {
                AddTalentSheet(character: imperium, store: store)
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
    
    private func removeTalent(_ talent: String) {
        guard let imperium = imperiumCharacter else { return }
        var talents = imperium.talentNames
        talents.removeAll { $0 == talent }
        imperium.talentNames = talents
        imperium.lastModified = Date()
        store.saveChanges()
    }
}

struct AddTalentSheet: View {
    let character: ImperiumCharacter
    @ObservedObject var store: CharacterStore
    @Environment(\.dismiss) private var dismiss
    
    var availableTalents: [String] {
        TalentDefinitions.allTalents.filter { talent in
            !character.talentNames.contains(talent)
        }
    }
    
    var body: some View {
        NavigationStack {
            List(availableTalents, id: \.self) { talent in
                Button(action: {
                    addTalent(talent)
                }) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(talent)
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        if let description = TalentDefinitions.talents[talent] {
                            Text(description)
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.leading)
                        }
                    }
                    .padding(.vertical, 2)
                }
                .buttonStyle(PlainButtonStyle())
            }
            .navigationTitle("Add Talent")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func addTalent(_ talent: String) {
        var talents = character.talentNames
        talents.append(talent)
        character.talentNames = talents
        character.lastModified = Date()
        store.saveChanges()
        dismiss()
    }
}