//
//  ReputationTabView.swift
//  ImperiumMaledictumCharacter
//
//  Created by User on 11.01.2025.
//

import SwiftUI

struct ReputationTab: View {
    let character: any BaseCharacter
    @ObservedObject var store: CharacterStore
    @Binding var isEditMode: Bool
    @State private var showingAddIndividualSheet = false
    @State private var editingIndividual: Reputation?
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
        GeometryReader { geometry in
            ScrollView {
                VStack(alignment: .leading, spacing: 30) {
                    if let imperium = imperiumCharacter {
                        // Faction Reputation Block
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Faction Reputation")
                                .font(.headline)
                            
                            LazyVStack(spacing: 8) {
                                ForEach(ImperiumFactionsList.factions, id: \.self) { faction in
                                    FactionReputationCard(
                                        faction: faction,
                                        reputation: getFactionReputation(for: faction, from: imperium),
                                        isEditMode: isEditMode,
                                        onValueChanged: { newValue in
                                            updateFactionReputation(faction: faction, value: newValue, character: imperium)
                                        }
                                    )
                                }
                            }
                        }
                        .padding()
                        
                        // Individual Reputation Block
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text("Individual Reputation")
                                    .font(.headline)
                                
                                Spacer()
                                
                                if isEditMode {
                                    Button(action: {
                                        showingAddIndividualSheet = true
                                    }) {
                                        Image(systemName: "plus.circle.fill")
                                            .foregroundColor(.blue)
                                            .font(.title2)
                                    }
                                }
                            }
                            .padding(.horizontal)
                            
                            let individuals = getIndividualReputations(from: imperium)
                            
                            if individuals.isEmpty {
                                VStack(spacing: 8) {
                                    Image(systemName: "person.2")
                                        .font(.largeTitle)
                                        .foregroundColor(.secondary)
                                    
                                    Text("No individual reputations")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    
                                    if isEditMode {
                                        Text("Tap + to add individual reputations")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 32)
                            } else {
                                LazyVStack(spacing: 8) {
                                    ForEach(individuals, id: \.displayName) { individual in
                                        IndividualReputationRow(
                                            individual: individual,
                                            isEditMode: isEditMode,
                                            onValueChanged: { newValue in
                                                updateIndividualReputation(individual: individual, value: newValue, character: imperium)
                                            },
                                            onEdit: {
                                                editingIndividual = individual
                                            },
                                            onDelete: {
                                                deleteIndividualReputation(individual: individual, character: imperium)
                                            }
                                        )
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                    }
                }
                .padding(.bottom, 80) // Extra space for floating buttons
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
        .sheet(isPresented: $showingAddIndividualSheet) {
            if let imperium = imperiumCharacter {
                AddIndividualReputationSheet(character: imperium, store: store)
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
        .sheet(item: $editingIndividual) { individual in
            if let imperium = imperiumCharacter {
                EditIndividualReputationSheet(
                    character: imperium,
                    store: store,
                    individual: individual
                )
            }
        }
        }
    }
    
    // MARK: - Helper Functions
    
    private func getFactionReputation(for faction: String, from character: ImperiumCharacter) -> Int {
        return character.reputations.first { $0.faction == faction && $0.individual.isEmpty }?.value ?? 0
    }
    
    private func getIndividualReputations(from character: ImperiumCharacter) -> [Reputation] {
        return character.reputations.filter { !$0.individual.isEmpty }
    }
    
    private func updateFactionReputation(faction: String, value: Int, character: ImperiumCharacter) {
        let originalSnapshot = store.createSnapshot(of: character)
        var reputations = character.reputations
        
        if let index = reputations.firstIndex(where: { $0.faction == faction && $0.individual.isEmpty }) {
            reputations[index].value = value
        } else {
            reputations.append(Reputation(faction: faction, individual: "", value: value))
        }
        
        character.reputations = reputations
        store.saveCharacterWithAutoChangeTracking(character, originalSnapshot: originalSnapshot)
    }
    
    private func updateIndividualReputation(individual: Reputation, value: Int, character: ImperiumCharacter) {
        let originalSnapshot = store.createSnapshot(of: character)
        var reputations = character.reputations
        
        if let index = reputations.firstIndex(where: { $0.faction == individual.faction && $0.individual == individual.individual }) {
            reputations[index].value = value
        }
        
        character.reputations = reputations
        store.saveCharacterWithAutoChangeTracking(character, originalSnapshot: originalSnapshot)
    }
    
    private func deleteIndividualReputation(individual: Reputation, character: ImperiumCharacter) {
        let originalSnapshot = store.createSnapshot(of: character)
        var reputations = character.reputations
        reputations.removeAll { $0.faction == individual.faction && $0.individual == individual.individual }
        character.reputations = reputations
        store.saveCharacterWithAutoChangeTracking(character, originalSnapshot: originalSnapshot)
    }
}

// MARK: - Faction Reputation Card

struct FactionReputationCard: View {
    let faction: String
    let reputation: Int
    let isEditMode: Bool
    let onValueChanged: (Int) -> Void
    
    var body: some View {
        if isEditMode {
            // Use horizontal layout in edit mode - single line as requested
            HStack(spacing: 8) {
                Text(faction)
                    .font(.caption)
                    .fontWeight(.medium)
                    .multilineTextAlignment(.leading)
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Spacer()
                
                HStack(spacing: 6) {
                    Button(action: {
                        onValueChanged(max(-100, reputation - 1))
                    }) {
                        Image(systemName: "minus")
                            .font(.caption2)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                            .frame(width: 24, height: 24)
                            .background(Color(.systemGray5))
                            .cornerRadius(4)
                    }
                    .disabled(reputation <= -100)
                    
                    Text("\(reputation)")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(reputationColor(reputation))
                        .frame(minWidth: 30)
                    
                    Button(action: {
                        onValueChanged(min(100, reputation + 1))
                    }) {
                        Image(systemName: "plus")
                            .font(.caption2)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                            .frame(width: 24, height: 24)
                            .background(Color(.systemGray5))
                            .cornerRadius(4)
                    }
                    .disabled(reputation >= 100)
                }
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 8)
            .background(Color(.systemGray6))
            .cornerRadius(8)
        } else {
            // Use horizontal layout in view mode for compactness
            HStack(spacing: 4) {
                Text(faction)
                    .font(.caption)
                    .fontWeight(.medium)
                    .multilineTextAlignment(.leading)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Spacer()
                
                Text("\(reputation)")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(reputationColor(reputation))
            }
            .padding(.vertical, 6)
            .padding(.horizontal, 8)
            .background(Color(.systemGray6))
            .cornerRadius(8)
        }
    }
    
    private func reputationColor(_ value: Int) -> Color {
        switch value {
        case let x where x > 50:
            return .green
        case let x where x > 25:
            return .blue
        case let x where x > 0:
            return .primary
        case 0:
            return .secondary
        case let x where x > -25:
            return .orange
        default:
            return .red
        }
    }
}

// MARK: - Individual Reputation Row

struct IndividualReputationRow: View {
    let individual: Reputation
    let isEditMode: Bool
    let onValueChanged: (Int) -> Void
    let onEdit: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        HStack(spacing: 8) {
            VStack(alignment: .leading, spacing: 2) {
                Text(individual.individual)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .lineLimit(1)
                
                Text(individual.faction)
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            Spacer()
            
            if isEditMode {
                HStack(spacing: 4) {
                    Button(action: {
                        onValueChanged(max(-100, individual.value - 1))
                    }) {
                        Image(systemName: "minus")
                            .font(.caption2)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                            .frame(width: 24, height: 24)
                            .background(Color(.systemGray5))
                            .cornerRadius(4)
                    }
                    .disabled(individual.value <= -100)
                    
                    Text("\(individual.value)")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(reputationColor(individual.value))
                        .frame(minWidth: 30)
                    
                    Button(action: {
                        onValueChanged(min(100, individual.value + 1))
                    }) {
                        Image(systemName: "plus")
                            .font(.caption2)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                            .frame(width: 24, height: 24)
                            .background(Color(.systemGray5))
                            .cornerRadius(4)
                    }
                    .disabled(individual.value >= 100)
                    
                    Button(action: onEdit) {
                        Image(systemName: "pencil")
                            .font(.caption2)
                            .foregroundColor(.blue)
                            .frame(width: 24, height: 24)
                            .background(Color(.systemBlue).opacity(0.2))
                            .cornerRadius(4)
                    }
                    
                    Button(action: onDelete) {
                        Image(systemName: "trash")
                            .font(.caption2)
                            .foregroundColor(.red)
                            .frame(width: 24, height: 24)
                            .background(Color(.systemRed).opacity(0.2))
                            .cornerRadius(4)
                    }
                }
            } else {
                Text("\(individual.value)")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(reputationColor(individual.value))
            }
        }
        .padding(.vertical, 6)
        .padding(.horizontal, 10)
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
    
    private func reputationColor(_ value: Int) -> Color {
        switch value {
        case let x where x > 50:
            return .green
        case let x where x > 25:
            return .blue
        case let x where x > 0:
            return .primary
        case 0:
            return .secondary
        case let x where x > -25:
            return .orange
        default:
            return .red
        }
    }
}

// MARK: - Add Individual Reputation Sheet

struct AddIndividualReputationSheet: View {
    let character: ImperiumCharacter
    @ObservedObject var store: CharacterStore
    @Environment(\.dismiss) private var dismiss
    
    @State private var individualName = ""
    @State private var selectedFaction = "Adeptus Astra Telepathica"
    @State private var reputationValue = 0
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Individual Details") {
                    TextField("Individual Name", text: $individualName)
                    
                    Picker("Faction", selection: $selectedFaction) {
                        ForEach(ImperiumFactionsList.factions, id: \.self) { faction in
                            Text(faction).tag(faction)
                        }
                    }
                }
                
                Section("Reputation Value") {
                    HStack {
                        Text("Reputation")
                        
                        Spacer()
                        
                        HStack(spacing: 8) {
                            Button(action: {
                                reputationValue = max(-100, reputationValue - 1)
                            }) {
                                Image(systemName: "minus")
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .foregroundColor(.primary)
                                    .frame(width: 32, height: 32)
                                    .background(Color(.systemGray5))
                                    .cornerRadius(6)
                            }
                            .buttonStyle(PlainButtonStyle())
                            .disabled(reputationValue <= -100)
                            
                            
                            Text("\(reputationValue)")
                                .font(.headline)
                                .fontWeight(.bold)
                                .frame(minWidth: 50)
                            
                            Button(action: {
                                reputationValue = min(100, reputationValue + 1)
                            }) {
                                Image(systemName: "plus")
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .foregroundColor(.primary)
                                    .frame(width: 32, height: 32)
                                    .background(Color(.systemGray5))
                                    .cornerRadius(6)
                            }
                            .buttonStyle(PlainButtonStyle())
                            .disabled(reputationValue >= 100)
                            
                        }
                    }
                }
            }
            .navigationTitle("Add Individual")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Add") {
                        addIndividual()
                    }
                    .disabled(individualName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
    
    private func addIndividual() {
        let trimmedName = individualName.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Check if individual already exists
        let existingIndividuals = character.reputations.filter { !$0.individual.isEmpty }
        let exists = existingIndividuals.contains { $0.individual == trimmedName && $0.faction == selectedFaction }
        
        if !exists {
            var reputations = character.reputations
            reputations.append(Reputation(faction: selectedFaction, individual: trimmedName, value: reputationValue))
            character.reputations = reputations
            store.saveChanges()
        }
        
        dismiss()
    }
}

// MARK: - Edit Individual Reputation Sheet

struct EditIndividualReputationSheet: View {
    let character: ImperiumCharacter
    @ObservedObject var store: CharacterStore
    let individual: Reputation
    @Environment(\.dismiss) private var dismiss
    
    @State private var individualName: String
    @State private var selectedFaction: String
    @State private var reputationValue: Int
    
    init(character: ImperiumCharacter, store: CharacterStore, individual: Reputation) {
        self.character = character
        self.store = store
        self.individual = individual
        self._individualName = State(initialValue: individual.individual)
        self._selectedFaction = State(initialValue: individual.faction)
        self._reputationValue = State(initialValue: individual.value)
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Individual Details") {
                    TextField("Individual Name", text: $individualName)
                    
                    Picker("Faction", selection: $selectedFaction) {
                        ForEach(ImperiumFactionsList.factions, id: \.self) { faction in
                            Text(faction).tag(faction)
                        }
                    }
                }
                
                Section("Reputation Value") {
                    HStack {
                        Text("Reputation")
                        
                        Spacer()
                        
                        HStack(spacing: 8) {
                            Button(action: {
                                reputationValue = max(-100, reputationValue - 1)
                            }) {
                                Image(systemName: "minus")
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .foregroundColor(.primary)
                                    .frame(width: 32, height: 32)
                                    .background(Color(.systemGray5))
                                    .cornerRadius(6)
                            }
                            .buttonStyle(PlainButtonStyle())
                            .disabled(reputationValue <= -100)
                            
                            
                            Text("\(reputationValue)")
                                .font(.headline)
                                .fontWeight(.bold)
                                .frame(minWidth: 50)
                            
                            Button(action: {
                                reputationValue = min(100, reputationValue + 1)
                            }) {
                                Image(systemName: "plus")
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .foregroundColor(.primary)
                                    .frame(width: 32, height: 32)
                                    .background(Color(.systemGray5))
                                    .cornerRadius(6)
                            }
                            .buttonStyle(PlainButtonStyle())
                            .disabled(reputationValue >= 100)
                            
                        }
                    }
                }
            }
            .navigationTitle("Edit Individual")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveChanges()
                    }
                    .disabled(individualName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
    
    private func saveChanges() {
        let trimmedName = individualName.trimmingCharacters(in: .whitespacesAndNewlines)
        
        var reputations = character.reputations
        
        // Remove the old entry
        reputations.removeAll { $0.faction == individual.faction && $0.individual == individual.individual }
        
        // Add the updated entry
        reputations.append(Reputation(faction: selectedFaction, individual: trimmedName, value: reputationValue))
        
        character.reputations = reputations
        store.saveChanges()
        dismiss()
    }
}

// MARK: - Preview

#Preview {
    let character = ImperiumCharacter()
    character.name = "Inquisitor Vex"
    character.reputations = [
        Reputation(faction: "Inquisition", individual: "", value: 75),
        Reputation(faction: "Adeptus Mechanicus", individual: "", value: -20),
        Reputation(faction: "Inquisition", individual: "Lord Inquisitor Caine", value: 50),
        Reputation(faction: "Adeptus Mechanicus", individual: "Tech-Priest Xerion", value: -15)
    ]
    
    return NavigationStack {
        ReputationTab(character: character, store: CharacterStore(), isEditMode: .constant(true))
    }
}