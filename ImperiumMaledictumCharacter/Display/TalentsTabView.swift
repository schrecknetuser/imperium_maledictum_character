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
    
    var imperiumCharacter: ImperiumCharacter? {
        return character as? ImperiumCharacter
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
        .sheet(isPresented: $showingAddTalentSheet) {
            if let imperium = imperiumCharacter {
                AddTalentSheet(character: imperium, store: store)
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