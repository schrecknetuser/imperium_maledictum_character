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
    @State private var showingAddPsychicPowerSheet = false
    @State private var showingUnifiedStatusPopup = false
    @State private var showingChangeHistoryPopup = false
    @State private var showingRemoveConfirmation = false
    @State private var talentToRemove: String?
    @State private var psychicPowerToRemove: String?
    
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
                    // Talents Section
                    Section {
                        DisclosureGroup("Talents") {
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
                                            talentToRemove = talent
                                            showingRemoveConfirmation = true
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
                        }
                    }
                    
                    // Psychic Powers Section
                    Section("Psychic Powers") {
                        // Group psychic powers by category
                        let groupedPowers = Dictionary(grouping: imperium.psychicPowers) { power in
                            PsychicPowerDefinitions.getCategoryForPower(power)
                        }
                        
                        ForEach(Array(PsychicPowerDefinitions.powerCategories.keys).sorted(), id: \.self) { category in
                            if let powersInCategory = groupedPowers[category], !powersInCategory.isEmpty {
                                DisclosureGroup(category) {
                                    ForEach(powersInCategory, id: \.self) { power in
                                        HStack {
                                            VStack(alignment: .leading, spacing: 4) {
                                                Text(power)
                                                    .font(.body)
                                                
                                                if let description = PsychicPowerDefinitions.powers[power] {
                                                    Text(description)
                                                        .font(.caption)
                                                        .foregroundColor(.secondary)
                                                        .multilineTextAlignment(.leading)
                                                }
                                            }
                                            
                                            Spacer()
                                            
                                            if isEditMode {
                                                Button(action: {
                                                    psychicPowerToRemove = power
                                                    showingRemoveConfirmation = true
                                                }) {
                                                    Image(systemName: "minus.circle.fill")
                                                        .foregroundColor(.red)
                                                }
                                                .buttonStyle(PlainButtonStyle())
                                            }
                                        }
                                        .padding(.vertical, 2)
                                    }
                                }
                            }
                        }
                        
                        if isEditMode {
                            Button(action: {
                                showingAddPsychicPowerSheet = true
                            }) {
                                HStack {
                                    Image(systemName: "plus.circle.fill")
                                        .foregroundColor(.purple)
                                    Text("Add Psychic Power")
                                        .foregroundColor(.purple)
                                    Spacer()
                                }
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                        
                        if imperium.psychicPowers.isEmpty && !isEditMode {
                            Text("No psychic powers selected")
                                .foregroundColor(.secondary)
                                .italic()
                        }
                    }
                } else {
                    Text("Talents and psychic powers not available for this character type")
                        .foregroundColor(.secondary)
                }
                
                // Invisible spacer for floating buttons
                Section {
                    Color.clear.frame(height: 76)
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                }
            }
            .navigationTitle("Talents & Powers")
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
                AddTalentSheet(character: imperium, store: store, isEditMode: isEditMode)
            }
        }
        .sheet(isPresented: $showingAddPsychicPowerSheet) {
            if let imperium = imperiumCharacter {
                AddPsychicPowerSheet(character: imperium, store: store, isEditMode: isEditMode)
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
        .alert("Remove Item", isPresented: $showingRemoveConfirmation) {
            Button("Cancel", role: .cancel) {
                talentToRemove = nil
                psychicPowerToRemove = nil
            }
            Button("Remove", role: .destructive) {
                if let talent = talentToRemove {
                    removeTalent(talent)
                    talentToRemove = nil
                } else if let power = psychicPowerToRemove {
                    removePsychicPower(power)
                    psychicPowerToRemove = nil
                }
            }
        } message: {
            if talentToRemove != nil {
                Text("Are you sure you want to remove this talent? This action cannot be undone.")
            } else if psychicPowerToRemove != nil {
                Text("Are you sure you want to remove this psychic power? This action cannot be undone.")
            } else {
                Text("Are you sure you want to remove this item? This action cannot be undone.")
            }
        }
    }
    
    private func removeTalent(_ talent: String) {
        guard let imperium = imperiumCharacter else { return }
        
        var talents = imperium.talentNames
        talents.removeAll { $0 == talent }
        imperium.talentNames = talents
        
        // Only use immediate change tracking if not in edit mode
        // When in edit mode, let the main "Done" button handle change tracking
        if !isEditMode {
            let originalSnapshot = store.createSnapshot(of: imperium)
            store.saveCharacterWithAutoChangeTracking(imperium, originalSnapshot: originalSnapshot)
        } else {
            store.saveChanges() // Just save to SwiftData without change tracking
        }
    }
    
    private func removePsychicPower(_ power: String) {
        guard let imperium = imperiumCharacter else { return }
        
        var powers = imperium.psychicPowers
        powers.removeAll { $0 == power }
        imperium.psychicPowers = powers
        
        // Only use immediate change tracking if not in edit mode
        // When in edit mode, let the main "Done" button handle change tracking
        if !isEditMode {
            let originalSnapshot = store.createSnapshot(of: imperium)
            store.saveCharacterWithAutoChangeTracking(imperium, originalSnapshot: originalSnapshot)
        } else {
            store.saveChanges() // Just save to SwiftData without change tracking
        }
    }
}

struct AddTalentSheet: View {
    let character: ImperiumCharacter
    @ObservedObject var store: CharacterStore
    let isEditMode: Bool
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
        
        // Only use immediate change tracking if not in edit mode
        // When in edit mode, let the main "Done" button handle change tracking
        if !isEditMode {
            let originalSnapshot = store.createSnapshot(of: character)
            store.saveCharacterWithAutoChangeTracking(character, originalSnapshot: originalSnapshot)
        } else {
            store.saveChanges() // Just save to SwiftData without change tracking
        }
        dismiss()
    }
}

struct AddPsychicPowerSheet: View {
    let character: ImperiumCharacter
    @ObservedObject var store: CharacterStore
    let isEditMode: Bool
    @Environment(\.dismiss) private var dismiss
    @State private var selectedCategory = "Minor Psychic Powers"
    
    var availableCategories: [String] {
        Array(PsychicPowerDefinitions.powerCategories.keys).sorted()
    }
    
    var availablePowers: [String] {
        PsychicPowerDefinitions.allPowers.filter { power in
            !character.psychicPowers.contains(power)
        }
    }
    
    var powersInSelectedCategory: [String] {
        availablePowers.filter { power in
            PsychicPowerDefinitions.getCategoryForPower(power) == selectedCategory
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                // Category picker
                Picker("Category", selection: $selectedCategory) {
                    ForEach(availableCategories, id: \.self) { category in
                        Text(category).tag(category)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                
                List(powersInSelectedCategory, id: \.self) { power in
                    Button(action: {
                        addPsychicPower(power)
                    }) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(power)
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            if let description = PsychicPowerDefinitions.powers[power] {
                                Text(description)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.leading)
                                    .lineLimit(3)
                            }
                        }
                        .padding(.vertical, 2)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .navigationTitle("Add Psychic Power")
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
    
    private func addPsychicPower(_ power: String) {
        var powers = character.psychicPowers
        powers.append(power)
        character.psychicPowers = powers
        
        // Only use immediate change tracking if not in edit mode
        // When in edit mode, let the main "Done" button handle change tracking
        if !isEditMode {
            let originalSnapshot = store.createSnapshot(of: character)
            store.saveCharacterWithAutoChangeTracking(character, originalSnapshot: originalSnapshot)
        } else {
            store.saveChanges() // Just save to SwiftData without change tracking
        }
        dismiss()
    }
}