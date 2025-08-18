//
//  ConditionsPopupView.swift
//  ImperiumMaledictumCharacter
//
//  Created by User on 11.01.2025.
//

import SwiftUI

struct ConditionsPopupView: View {
    @Binding var character: ImperiumCharacter
    var store: CharacterStore
    @Environment(\.dismiss) private var dismiss
    @State private var showingAddConditionSheet = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                if character.conditionsList.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.system(size: 48))
                            .foregroundColor(.orange)
                        
                        Text("No Conditions")
                            .font(.headline)
                        
                        Text("Your character has no active conditions.")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding()
                    
                    Spacer()
                } else {
                    List {
                        ForEach(character.conditionsList) { condition in
                            ConditionRowView(condition: condition)
                        }
                        .onDelete(perform: removeConditions)
                    }
                }
                
                Button(action: {
                    showingAddConditionSheet = true
                }) {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                        Text("Add Condition")
                            .font(.headline)
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.orange)
                    .cornerRadius(12)
                }
                .padding()
            }
            .navigationTitle("Conditions")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .sheet(isPresented: $showingAddConditionSheet) {
            AddConditionSheet(character: $character, store: store)
        }
    }
    
    private func removeConditions(at offsets: IndexSet) {
        var conditions = character.conditionsList
        conditions.remove(atOffsets: offsets)
        character.conditionsList = conditions
        character.lastModified = Date()
        store.saveChanges()
    }
}

struct ConditionRowView: View {
    let condition: Condition
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(condition.name)
                .font(.headline)
                .foregroundColor(.primary)
            
            Text(condition.description)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.leading)
        }
        .padding(.vertical, 4)
    }
}

struct AddConditionSheet: View {
    @Binding var character: ImperiumCharacter
    var store: CharacterStore
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            List(ConditionDefinitions.allConditions) { condition in
                Button(action: {
                    var conditions = character.conditionsList
                    conditions.append(condition)
                    character.conditionsList = conditions
                    character.lastModified = Date()
                    store.saveChanges()
                    dismiss()
                }) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(condition.name)
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        Text(condition.description)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.leading)
                    }
                    .padding(.vertical, 4)
                }
                .buttonStyle(.plain)
            }
            .navigationTitle("Add Condition")
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
}