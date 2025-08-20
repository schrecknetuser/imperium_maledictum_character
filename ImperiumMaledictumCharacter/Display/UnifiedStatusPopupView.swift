//
//  UnifiedStatusPopupView.swift
//  ImperiumMaledictumCharacter
//
//  Created by User on 11.01.2025.
//

import SwiftUI

struct UnifiedStatusPopupView: View {
    @Binding var character: ImperiumCharacter
    var store: CharacterStore
    @Environment(\.dismiss) private var dismiss
    @State private var selectedTab = 0
    
    var body: some View {
        NavigationStack {
            TabView(selection: $selectedTab) {
                // Status Tab (First)
                StatusContentView(character: $character, store: store)
                    .tabItem {
                        Image(systemName: "heart.text.square")
                        Text("Status")
                    }
                    .tag(0)
                
                // Injuries Tab (Second)
                InjuriesContentView(character: $character, store: store)
                    .tabItem {
                        Image(systemName: "bandage")
                        Text("Injuries")
                    }
                    .tag(1)
                
                // Conditions Tab (Third)
                ConditionsContentView(character: $character, store: store)
                    .tabItem {
                        Image(systemName: "exclamationmark.triangle")
                        Text("Conditions")
                    }
                    .tag(2)
            }
            .navigationTitle("Character Status")
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

// MARK: - Status Content View (from StatusPopupView)

struct StatusContentView: View {
    @Binding var character: ImperiumCharacter
    var store: CharacterStore
    
    // Local state to force UI updates
    @State private var wounds: Int = 0
    @State private var corruption: Int = 0
    @State private var fate: Int = 0
    @State private var spentFate: Int = 0
    
    // Store original snapshot for change tracking
    @State private var originalSnapshot: CharacterSnapshot?
    
    var body: some View {
        Form {
            Section("Character Status") {
                // Wounds
                VStack(alignment: .leading, spacing: 8) {
                    Text("Wounds")
                        .font(.headline)
                    
                    HStack {
                        Button(action: {
                            if wounds > 0 {
                                wounds -= 1
                                updateCharacter()
                            }
                        }) {
                            Image(systemName: "minus.circle.fill")
                                .font(.title2)
                                .foregroundColor(.red)
                        }
                        .buttonStyle(PlainButtonStyle())
                        .disabled(wounds <= 0)
                        
                        Spacer()
                        
                        Text("\(wounds)")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Spacer()
                        
                        Button(action: {
                            if wounds < character.calculateMaxWounds() {
                                wounds += 1
                                updateCharacter()
                            }
                        }) {
                            Image(systemName: "plus.circle.fill")
                                .font(.title2)
                                .foregroundColor(.red)
                        }
                        .buttonStyle(PlainButtonStyle())
                        .disabled(wounds >= character.calculateMaxWounds())
                    }
                    
                    Text("Wounds Threshold: \(character.calculateMaxWounds())")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                // Corruption
                VStack(alignment: .leading, spacing: 8) {
                    Text("Corruption")
                        .font(.headline)
                    
                    HStack {
                        Button(action: {
                            if corruption > 0 {
                                corruption -= 1
                                updateCharacter()
                            }
                        }) {
                            Image(systemName: "minus.circle.fill")
                                .font(.title2)
                                .foregroundColor(.purple)
                        }
                        .buttonStyle(PlainButtonStyle())
                        .disabled(corruption <= 0)
                        
                        Spacer()
                        
                        Text("\(corruption)")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Spacer()
                        
                        Button(action: {
                            corruption += 1
                            updateCharacter()
                        }) {
                            Image(systemName: "plus.circle.fill")
                                .font(.title2)
                                .foregroundColor(.purple)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    
                    Text("Corruption Threshold: \(character.calculateCorruptionThreshold())")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                // Critical Wounds (automatic count)
                VStack(alignment: .leading, spacing: 8) {
                    Text("Critical Wounds")
                        .font(.headline)
                    
                    HStack {
                        Spacer()
                        
                        Text("\(character.countActiveCriticalWounds())")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Spacer()
                    }
                    
                    Text("Critical Wounds Threshold: \(character.calculateCriticalWoundsThreshold())")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Section("Fate Points") {
                // Fate
                VStack(alignment: .leading, spacing: 8) {
                    Text("Fate")
                        .font(.headline)
                    
                    HStack {
                        Button(action: {
                            if fate > 0 {
                                fate -= 1
                                // Adjust spent fate if it exceeds current fate
                                if spentFate > fate {
                                    spentFate = fate
                                }
                                updateCharacter()
                            }
                        }) {
                            Image(systemName: "minus.circle.fill")
                                .font(.title2)
                                .foregroundColor(.yellow)
                        }
                        .buttonStyle(PlainButtonStyle())
                        .disabled(fate <= 0)
                        
                        Spacer()
                        
                        Text("\(fate)")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Spacer()
                        
                        Button(action: {
                            fate += 1
                            updateCharacter()
                        }) {
                            Image(systemName: "plus.circle.fill")
                                .font(.title2)
                                .foregroundColor(.yellow)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                
                // Spent Fate
                VStack(alignment: .leading, spacing: 8) {
                    Text("Spent Fate")
                        .font(.headline)
                    
                    HStack {
                        Button(action: {
                            if spentFate > 0 {
                                spentFate -= 1
                                updateCharacter()
                            }
                        }) {
                            Image(systemName: "minus.circle.fill")
                                .font(.title2)
                                .foregroundColor(.orange)
                        }
                        .buttonStyle(PlainButtonStyle())
                        .disabled(spentFate <= 0)
                        
                        Spacer()
                        
                        Text("\(spentFate)")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Spacer()
                        
                        Button(action: {
                            if spentFate < fate {
                                spentFate += 1
                                updateCharacter()
                            }
                        }) {
                            Image(systemName: "plus.circle.fill")
                                .font(.title2)
                                .foregroundColor(.orange)
                        }
                        .buttonStyle(PlainButtonStyle())
                        .disabled(spentFate >= fate)
                    }
                    
                    Text("Available: \(fate - spentFate)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .onAppear {
            // Initialize state from character
            wounds = character.wounds
            corruption = character.corruption
            fate = character.fate
            spentFate = character.spentFate
            
            // Create original snapshot for change tracking
            originalSnapshot = store.createSnapshot(of: character)
        }
    }
    
    private func updateCharacter() {
        character.wounds = wounds
        character.corruption = corruption
        character.fate = fate
        character.spentFate = spentFate
        character.lastModified = Date()
        
        // Save with change tracking if we have the original snapshot
        if let snapshot = originalSnapshot {
            store.saveCharacterWithAutoChangeTracking(character, originalSnapshot: snapshot)
        } else {
            store.saveChanges()
        }
    }
}

// MARK: - Injuries Content View (from InjuriesPopupView)

struct InjuriesContentView: View {
    @Binding var character: ImperiumCharacter
    var store: CharacterStore
    @State private var selectedTab = 0
    @State private var showingRemoveConfirmation = false
    @State private var pendingRemoval: (() -> Void)?
    
    var body: some View {
        TabView(selection: $selectedTab) {
            InjuryListView(
                title: "Head Injuries",
                injuries: character.headInjuriesList,
                availableWounds: CriticalWoundDefinitions.headWounds,
                onAdd: { wound in
                    let originalSnapshot = store.createSnapshot(of: character)
                    
                    var current = character.headInjuriesList
                    current.append(wound)
                    character.headInjuriesList = current
                    character.lastModified = Date()
                    
                    store.saveCharacterWithAutoChangeTracking(character, originalSnapshot: originalSnapshot)
                },
                onRemove: { indices in
                    pendingRemoval = {
                        let originalSnapshot = store.createSnapshot(of: character)
                        
                        var current = character.headInjuriesList
                        for index in indices.sorted(by: >) {
                            current.remove(at: index)
                        }
                        character.headInjuriesList = current
                        character.lastModified = Date()
                        
                        store.saveCharacterWithAutoChangeTracking(character, originalSnapshot: originalSnapshot)
                    }
                    showingRemoveConfirmation = true
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
                    let originalSnapshot = store.createSnapshot(of: character)
                    
                    var current = character.armInjuriesList
                    current.append(wound)
                    character.armInjuriesList = current
                    character.lastModified = Date()
                    
                    store.saveCharacterWithAutoChangeTracking(character, originalSnapshot: originalSnapshot)
                },
                onRemove: { indices in
                    pendingRemoval = {
                        let originalSnapshot = store.createSnapshot(of: character)
                        
                        var current = character.armInjuriesList
                        for index in indices.sorted(by: >) {
                            current.remove(at: index)
                        }
                        character.armInjuriesList = current
                        character.lastModified = Date()
                        
                        store.saveCharacterWithAutoChangeTracking(character, originalSnapshot: originalSnapshot)
                    }
                    showingRemoveConfirmation = true
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
                    let originalSnapshot = store.createSnapshot(of: character)
                    
                    var current = character.bodyInjuriesList
                    current.append(wound)
                    character.bodyInjuriesList = current
                    character.lastModified = Date()
                    
                    store.saveCharacterWithAutoChangeTracking(character, originalSnapshot: originalSnapshot)
                },
                onRemove: { indices in
                    pendingRemoval = {
                        let originalSnapshot = store.createSnapshot(of: character)
                        
                        var current = character.bodyInjuriesList
                        for index in indices.sorted(by: >) {
                            current.remove(at: index)
                        }
                        character.bodyInjuriesList = current
                        character.lastModified = Date()
                        
                        store.saveCharacterWithAutoChangeTracking(character, originalSnapshot: originalSnapshot)
                    }
                    showingRemoveConfirmation = true
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
                    let originalSnapshot = store.createSnapshot(of: character)
                    
                    var current = character.legInjuriesList
                    current.append(wound)
                    character.legInjuriesList = current
                    character.lastModified = Date()
                    
                    store.saveCharacterWithAutoChangeTracking(character, originalSnapshot: originalSnapshot)
                },
                onRemove: { indices in
                    pendingRemoval = {
                        let originalSnapshot = store.createSnapshot(of: character)
                        
                        var current = character.legInjuriesList
                        for index in indices.sorted(by: >) {
                            current.remove(at: index)
                        }
                        character.legInjuriesList = current
                        character.lastModified = Date()
                        
                        store.saveCharacterWithAutoChangeTracking(character, originalSnapshot: originalSnapshot)
                    }
                    showingRemoveConfirmation = true
                }
            )
            .tabItem {
                Image(systemName: "figure.walk")
                Text("Leg")
            }
            .tag(3)
        }
        .alert("Remove Injury", isPresented: $showingRemoveConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Remove", role: .destructive) {
                pendingRemoval?()
            }
        } message: {
            Text("Are you sure you want to remove this injury? This action cannot be undone.")
        }
    }
}

// MARK: - Conditions Content View (from ConditionsPopupView)

struct ConditionsContentView: View {
    @Binding var character: ImperiumCharacter
    var store: CharacterStore
    @State private var showingAddConditionSheet = false
    @State private var showingRemoveConfirmation = false
    @State private var conditionToRemove: IndexSet?
    
    var body: some View {
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
        .sheet(isPresented: $showingAddConditionSheet) {
            AddConditionSheet(character: $character, store: store)
        }
        .alert("Remove Condition", isPresented: $showingRemoveConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Remove", role: .destructive) {
                if let indicesToRemove = conditionToRemove {
                    confirmRemoveConditions(at: indicesToRemove)
                }
            }
        } message: {
            Text("Are you sure you want to remove this condition? This action cannot be undone.")
        }
    }
    
    private func removeConditions(at offsets: IndexSet) {
        conditionToRemove = offsets
        showingRemoveConfirmation = true
    }
    
    private func confirmRemoveConditions(at offsets: IndexSet) {
        let originalSnapshot = store.createSnapshot(of: character)
        
        var conditions = character.conditionsList
        conditions.remove(atOffsets: offsets)
        character.conditionsList = conditions
        character.lastModified = Date()
        
        store.saveCharacterWithAutoChangeTracking(character, originalSnapshot: originalSnapshot)
    }
}