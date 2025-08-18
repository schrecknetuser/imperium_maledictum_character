//
//  InjuriesPopupView.swift
//  ImperiumMaledictumCharacter
//
//  Created by User on 11.01.2025.
//

import SwiftUI

struct InjuriesPopupView: View {
    @Binding var character: ImperiumCharacter
    var store: CharacterStore
    @Environment(\.dismiss) private var dismiss
    @State private var selectedTab = 0
    
    var body: some View {
        NavigationStack {
            TabView(selection: $selectedTab) {
                InjuryListView(
                    title: "Head Injuries",
                    injuries: character.headInjuriesList,
                    availableWounds: CriticalWoundDefinitions.headWounds,
                    onAdd: { wound in
                        var current = character.headInjuriesList
                        current.append(wound)
                        character.headInjuriesList = current
                        character.lastModified = Date()
                        store.saveChanges()
                    },
                    onRemove: { indices in
                        var current = character.headInjuriesList
                        for index in indices.sorted(by: >) {
                            current.remove(at: index)
                        }
                        character.headInjuriesList = current
                        character.lastModified = Date()
                        store.saveChanges()
                    }
                )
                .tabItem {
                    Image(systemName: "brain.head.profile")
                    Text("Head")
                }
                .tag(0)
                
                InjuryListView(
                    title: "Arm Injuries",
                    injuries: character.armInjuriesList,
                    availableWounds: CriticalWoundDefinitions.armWounds,
                    onAdd: { wound in
                        var current = character.armInjuriesList
                        current.append(wound)
                        character.armInjuriesList = current
                        character.lastModified = Date()
                        store.saveChanges()
                    },
                    onRemove: { indices in
                        var current = character.armInjuriesList
                        for index in indices.sorted(by: >) {
                            current.remove(at: index)
                        }
                        character.armInjuriesList = current
                        character.lastModified = Date()
                        store.saveChanges()
                    }
                )
                .tabItem {
                    Image(systemName: "hand.raised")
                    Text("Arm")
                }
                .tag(1)
                
                InjuryListView(
                    title: "Body Injuries",
                    injuries: character.bodyInjuriesList,
                    availableWounds: CriticalWoundDefinitions.bodyWounds,
                    onAdd: { wound in
                        var current = character.bodyInjuriesList
                        current.append(wound)
                        character.bodyInjuriesList = current
                        character.lastModified = Date()
                        store.saveChanges()
                    },
                    onRemove: { indices in
                        var current = character.bodyInjuriesList
                        for index in indices.sorted(by: >) {
                            current.remove(at: index)
                        }
                        character.bodyInjuriesList = current
                        character.lastModified = Date()
                        store.saveChanges()
                    }
                )
                .tabItem {
                    Image(systemName: "person")
                    Text("Body")
                }
                .tag(2)
                
                InjuryListView(
                    title: "Leg Injuries",
                    injuries: character.legInjuriesList,
                    availableWounds: CriticalWoundDefinitions.legWounds,
                    onAdd: { wound in
                        var current = character.legInjuriesList
                        current.append(wound)
                        character.legInjuriesList = current
                        character.lastModified = Date()
                        store.saveChanges()
                    },
                    onRemove: { indices in
                        var current = character.legInjuriesList
                        for index in indices.sorted(by: >) {
                            current.remove(at: index)
                        }
                        character.legInjuriesList = current
                        character.lastModified = Date()
                        store.saveChanges()
                    }
                )
                .tabItem {
                    Image(systemName: "figure.walk")
                    Text("Leg")
                }
                .tag(3)
            }
            .navigationTitle("Critical Injuries")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        character.lastModified = Date()
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Injury List View

struct InjuryListView: View {
    let title: String
    let injuries: [CriticalWound]
    let availableWounds: [CriticalWound]
    let onAdd: (CriticalWound) -> Void
    let onRemove: (IndexSet) -> Void
    
    @State private var showingAddSheet = false
    
    var body: some View {
        List {
            Section {
                ForEach(injuries) { injury in
                    VStack(alignment: .leading, spacing: 8) {
                        Text(injury.name)
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        Text(injury.description)
                            .font(.body)
                            .foregroundColor(.secondary)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Treatment:")
                                .font(.caption)
                                .fontWeight(.semibold)
                            Text(injury.treatment)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.vertical, 4)
                }
                .onDelete(perform: onRemove)
            } header: {
                HStack {
                    Text(title)
                    Spacer()
                    Button("Add Injury") {
                        showingAddSheet = true
                    }
                    .font(.caption)
                }
            }
            
            if injuries.isEmpty {
                Text("No \(title.lowercased()) recorded")
                    .foregroundColor(.secondary)
                    .italic()
            }
        }
        .sheet(isPresented: $showingAddSheet) {
            AddInjurySheet(
                availableWounds: availableWounds,
                onAdd: onAdd
            )
        }
    }
}

// MARK: - Add Injury Sheet

struct AddInjurySheet: View {
    let availableWounds: [CriticalWound]
    let onAdd: (CriticalWound) -> Void
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(availableWounds) { wound in
                    Button {
                        onAdd(wound)
                        dismiss()
                    } label: {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(wound.name)
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            Text(wound.description)
                                .font(.body)
                                .foregroundColor(.secondary)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Treatment:")
                                    .font(.caption)
                                    .fontWeight(.semibold)
                                Text(wound.treatment)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                    .buttonStyle(.plain)
                }
            }
            .navigationTitle("Add Critical Wound")
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