//
//  CharacterCreationWizard.swift
//  ImperiumMaledictumCharacter
//
//  Created by User on 11.01.2025.
//

import SwiftUI

struct CharacterCreationWizard: View {
    @ObservedObject var store: CharacterStore
    @Environment(\.dismiss) private var dismiss
    
    @State private var character: ImperiumCharacter
    @State private var currentStage: Int = 0
    
    init(store: CharacterStore, existingCharacter: (any BaseCharacter)? = nil) {
        self.store = store
        
        if let existing = existingCharacter as? ImperiumCharacter {
            self._character = State(initialValue: existing)
            self._currentStage = State(initialValue: existing.creationProgress)
        } else {
            self._character = State(initialValue: store.createNewCharacter())
            self._currentStage = State(initialValue: 0)
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Progress bar
                ProgressView(value: Double(currentStage), total: Double(CreationStages.totalStages))
                    .padding()
                
                // Stage content
                ScrollView {
                    VStack(spacing: 20) {
                        stageContent
                    }
                    .padding()
                }
                
                // Navigation buttons
                HStack {
                    if currentStage > 0 {
                        Button("Previous") {
                            withAnimation {
                                currentStage -= 1
                            }
                        }
                        .buttonStyle(.bordered)
                    }
                    
                    Spacer()
                    
                    if currentStage < CreationStages.totalStages - 1 {
                        Button("Next") {
                            if canProceedToNextStage() {
                                character.creationProgress = max(character.creationProgress, currentStage + 1)
                                withAnimation {
                                    currentStage += 1
                                }
                            }
                        }
                        .buttonStyle(.borderedProminent)
                        .disabled(!canProceedToNextStage())
                    } else {
                        Button("Complete") {
                            completeCreation()
                        }
                        .buttonStyle(.borderedProminent)
                        .disabled(!canCompleteCreation())
                    }
                }
                .padding()
            }
            .navigationTitle(CreationStages.stageName(for: currentStage))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    private var stageContent: some View {
        switch currentStage {
        case 0:
            BasicInfoStage(character: $character)
        case 1:
            CharacteristicsStage(character: $character)
        case 2:
            OriginStage(character: $character)
        case 3:
            FactionStage(character: $character)
        case 4:
            RoleStage(character: $character)
        case 5:
            CompletionStage(character: $character)
        default:
            Text("Unknown stage")
        }
    }
    
    private func canProceedToNextStage() -> Bool {
        switch currentStage {
        case 0: // Basic Info
            return !character.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        case 1: // Characteristics
            return true // Can proceed with default allocation
        case 2: // Origin
            return !character.homeworld.isEmpty
        case 3: // Faction
            return !character.faction.isEmpty
        case 4: // Role
            return !character.role.isEmpty
        case 5: // Complete
            return true
        default:
            return false
        }
    }
    
    private func canCompleteCreation() -> Bool {
        return !character.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
               !character.faction.isEmpty &&
               !character.role.isEmpty &&
               !character.homeworld.isEmpty
    }
    
    private func completeCreation() {
        character.completeCreation()
        
        // Add character to store if it's new
        if !store.characters.contains(where: { $0.id == character.id }) {
            store.addCharacter(character)
        } else {
            store.saveChanges()
        }
        
        dismiss()
    }
}

// MARK: - Creation Stages

struct BasicInfoStage: View {
    @Binding var character: ImperiumCharacter
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Group {
                Text("Character Information")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("Enter your character's name and the campaign they will be part of.")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                VStack(alignment: .leading, spacing: 12) {
                    Text("Character Name")
                        .font(.headline)
                    TextField("Enter character name", text: $character.name)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                
                VStack(alignment: .leading, spacing: 12) {
                    Text("Campaign Name")
                        .font(.headline)
                    TextField("Enter campaign name (optional)", text: $character.campaign)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
            }
        }
    }
}

struct CharacteristicsStage: View {
    @Binding var character: ImperiumCharacter
    @State private var allocatedPoints: [String: Int] = [:]
    @State private var remainingPoints: Int = 90
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Characteristics")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("Allocate 90 points among your characteristics. Each characteristic starts at 20 and each point increases it by 5. Maximum of 100 per characteristic.")
                .font(.caption)
                .foregroundColor(.secondary)
            
            HStack {
                Text("Remaining Points:")
                    .font(.headline)
                Spacer()
                Text("\(remainingPoints)")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(remainingPoints < 0 ? .red : .primary)
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(8)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 16) {
                CharacteristicAllocationField(
                    name: CharacteristicNames.weaponSkill,
                    baseValue: 20,
                    allocatedPoints: binding(for: CharacteristicNames.weaponSkill),
                    onPointsChanged: updateRemainingPoints
                )
                CharacteristicAllocationField(
                    name: CharacteristicNames.ballisticSkill,
                    baseValue: 20,
                    allocatedPoints: binding(for: CharacteristicNames.ballisticSkill),
                    onPointsChanged: updateRemainingPoints
                )
                CharacteristicAllocationField(
                    name: CharacteristicNames.strength,
                    baseValue: 20,
                    allocatedPoints: binding(for: CharacteristicNames.strength),
                    onPointsChanged: updateRemainingPoints
                )
                CharacteristicAllocationField(
                    name: CharacteristicNames.toughness,
                    baseValue: 20,
                    allocatedPoints: binding(for: CharacteristicNames.toughness),
                    onPointsChanged: updateRemainingPoints
                )
                CharacteristicAllocationField(
                    name: CharacteristicNames.agility,
                    baseValue: 20,
                    allocatedPoints: binding(for: CharacteristicNames.agility),
                    onPointsChanged: updateRemainingPoints
                )
                CharacteristicAllocationField(
                    name: CharacteristicNames.intelligence,
                    baseValue: 20,
                    allocatedPoints: binding(for: CharacteristicNames.intelligence),
                    onPointsChanged: updateRemainingPoints
                )
                CharacteristicAllocationField(
                    name: CharacteristicNames.willpower,
                    baseValue: 20,
                    allocatedPoints: binding(for: CharacteristicNames.willpower),
                    onPointsChanged: updateRemainingPoints
                )
                CharacteristicAllocationField(
                    name: CharacteristicNames.fellowship,
                    baseValue: 20,
                    allocatedPoints: binding(for: CharacteristicNames.fellowship),
                    onPointsChanged: updateRemainingPoints
                )
                CharacteristicAllocationField(
                    name: CharacteristicNames.perception,
                    baseValue: 20,
                    allocatedPoints: binding(for: CharacteristicNames.perception),
                    onPointsChanged: updateRemainingPoints
                )
            }
            
            Text("Note: You can continue without allocating all points or allocate more than allowed. Adjustments can be made later.")
                .font(.caption)
                .foregroundColor(.secondary)
                .italic()
        }
        .onAppear {
            initializeAllocatedPoints()
        }
        .onDisappear {
            saveCharacteristicsToCharacter()
        }
    }
    
    private func initializeAllocatedPoints() {
        let characteristics = character.characteristics
        for name in CharacteristicNames.allCharacteristics {
            let characteristic = characteristics[name] ?? Characteristic(name: name, initialValue: 20, advances: 0)
            allocatedPoints[name] = characteristic.initialValue - 20
        }
        updateRemainingPoints()
    }
    
    private func saveCharacteristicsToCharacter() {
        var characteristics = character.characteristics
        for (name, points) in allocatedPoints {
            characteristics[name] = Characteristic(name: name, initialValue: 20 + (points * 5), advances: 0)
        }
        character.characteristics = characteristics
    }
    
    private func binding(for characteristic: String) -> Binding<Int> {
        return Binding(
            get: { allocatedPoints[characteristic] ?? 0 },
            set: { newValue in 
                allocatedPoints[characteristic] = newValue
                updateRemainingPoints()
            }
        )
    }
    
    private func updateRemainingPoints() {
        let totalAllocated = allocatedPoints.values.reduce(0, +)
        remainingPoints = 90 - totalAllocated
    }
}

struct CharacteristicAllocationField: View {
    let name: String
    let baseValue: Int
    @Binding var allocatedPoints: Int
    let onPointsChanged: () -> Void
    
    var finalValue: Int {
        return baseValue + (allocatedPoints * 5)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(name)
                .font(.headline)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
            
            HStack {
                Button("-") {
                    if allocatedPoints > 0 {
                        allocatedPoints -= 1
                        onPointsChanged()
                    }
                }
                .buttonStyle(.bordered)
                .disabled(allocatedPoints <= 0)
                
                Spacer()
                
                VStack {
                    Text("\(finalValue)")
                        .font(.title2)
                        .fontWeight(.bold)
                    Text("(\(allocatedPoints) pts)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .frame(minWidth: 60)
                
                Spacer()
                
                Button("+") {
                    if finalValue < 100 {
                        allocatedPoints += 1
                        onPointsChanged()
                    }
                }
                .buttonStyle(.bordered)
                .disabled(finalValue >= 100)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
}

// MARK: - New Stage Implementations

struct OriginStage: View {
    @Binding var character: ImperiumCharacter
    @State private var selectedChoice: String = ""
    
    var selectedOrigin: Origin? {
        return OriginDefinitions.getOrigin(by: character.homeworld)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Origin")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("Choose your character's origin world, which determines their background and starting bonuses.")
                .font(.caption)
                .foregroundColor(.secondary)
            
            VStack(alignment: .leading, spacing: 12) {
                Text("Origin World")
                    .font(.headline)
                
                Picker("Select Origin", selection: $character.homeworld) {
                    Text("Select origin...").tag("")
                    ForEach(OriginDefinitions.allOrigins, id: \.name) { origin in
                        Text(origin.name).tag(origin.name)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            
            if let origin = selectedOrigin {
                VStack(alignment: .leading, spacing: 12) {
                    Text(origin.description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text("Bonuses:")
                        .font(.headline)
                    
                    Text("• +\(origin.mandatoryBonus.bonus) \(origin.mandatoryBonus.characteristic)")
                        .font(.subheadline)
                    
                    Text("Choice of:")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        ForEach(origin.choiceBonus.indices, id: \.self) { index in
                            let bonus = origin.choiceBonus[index]
                            HStack {
                                Button(action: {
                                    selectedChoice = bonus.characteristic
                                }) {
                                    HStack {
                                        Image(systemName: selectedChoice == bonus.characteristic ? "checkmark.circle.fill" : "circle")
                                        Text("+\(bonus.bonus) \(bonus.characteristic)")
                                    }
                                }
                                .buttonStyle(.plain)
                                .foregroundColor(selectedChoice == bonus.characteristic ? .blue : .primary)
                                
                                Spacer()
                            }
                        }
                    }
                    
                    if !origin.grantedEquipment.isEmpty {
                        Text("Starting Equipment:")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                        
                        ForEach(origin.grantedEquipment, id: \.self) { equipment in
                            Text("• \(equipment)")
                                .font(.subheadline)
                        }
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(8)
            }
        }
    }
}
struct FactionStage: View {
    @Binding var character: ImperiumCharacter
    @State private var selectedChoice: String = ""
    
    var selectedFaction: Faction? {
        return FactionDefinitions.getFaction(by: character.faction)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Faction")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("Choose your character's faction, which determines their training, resources, and connections.")
                .font(.caption)
                .foregroundColor(.secondary)
            
            VStack(alignment: .leading, spacing: 12) {
                Text("Imperial Faction")
                    .font(.headline)
                
                Picker("Select Faction", selection: $character.faction) {
                    Text("Select faction...").tag("")
                    ForEach(FactionDefinitions.allFactions, id: \.name) { faction in
                        Text(faction.name).tag(faction.name)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            
            if let faction = selectedFaction {
                ScrollView {
                    VStack(alignment: .leading, spacing: 12) {
                        Text(faction.description)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Text("Characteristic Bonuses:")
                            .font(.headline)
                        
                        Text("• +\(faction.mandatoryBonus.bonus) \(faction.mandatoryBonus.characteristic)")
                            .font(.subheadline)
                        
                        Text("Choice of:")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            ForEach(faction.choiceBonus.indices, id: \.self) { index in
                                let bonus = faction.choiceBonus[index]
                                HStack {
                                    Button(action: {
                                        selectedChoice = bonus.characteristic
                                    }) {
                                        HStack {
                                            Image(systemName: selectedChoice == bonus.characteristic ? "checkmark.circle.fill" : "circle")
                                            Text("+\(bonus.bonus) \(bonus.characteristic)")
                                        }
                                    }
                                    .buttonStyle(.plain)
                                    .foregroundColor(selectedChoice == bonus.characteristic ? .blue : .primary)
                                    
                                    Spacer()
                                }
                            }
                        }
                        
                        Text("Skills (5 advances to distribute):")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                        
                        Text(faction.skillAdvances.joined(separator: ", "))
                            .font(.subheadline)
                        
                        Text("Influence: +1 with \(faction.influenceBonus)")
                            .font(.subheadline)
                        
                        if !faction.talents.isEmpty {
                            Text("Talents:")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                            
                            ForEach(faction.talents, id: \.self) { talent in
                                Text("• \(talent)")
                                    .font(.subheadline)
                            }
                        }
                        
                        Text("Equipment:")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                        
                        ForEach(faction.equipment, id: \.self) { equipment in
                            Text("• \(equipment)")
                                .font(.subheadline)
                        }
                        
                        Text("Starting Solars: \(faction.solars)")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                    }
                }
                .frame(maxHeight: 300)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(8)
            }
        }
    }
}

struct RoleStage: View {
    @Binding var character: ImperiumCharacter
    
    var selectedRole: Role? {
        return RoleDefinitions.getRole(by: character.role)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Role")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("Choose your character's role, which determines their specialization and starting abilities.")
                .font(.caption)
                .foregroundColor(.secondary)
            
            VStack(alignment: .leading, spacing: 12) {
                Text("Character Role")
                    .font(.headline)
                
                Picker("Select Role", selection: $character.role) {
                    Text("Select role...").tag("")
                    ForEach(RoleDefinitions.allRoles, id: \.name) { role in
                        Text(role.name).tag(role.name)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            
            if let role = selectedRole {
                ScrollView {
                    VStack(alignment: .leading, spacing: 12) {
                        Text(role.description)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Text("Talent Choices (\(role.talentCount) from):")
                            .font(.headline)
                        
                        ForEach(role.talentChoices, id: \.self) { talent in
                            Text("• \(talent)")
                                .font(.subheadline)
                        }
                        
                        Text("Skill Advances (\(role.skillAdvanceCount) to distribute):")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                        
                        Text(role.skillAdvances.joined(separator: ", "))
                            .font(.subheadline)
                        
                        Text("Specialization Advances (\(role.specializationAdvanceCount) to distribute):")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                        
                        Text(role.specializationAdvances.joined(separator: ", "))
                            .font(.subheadline)
                        
                        if !role.weaponChoices.isEmpty {
                            Text("Weapon Choices:")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                            
                            ForEach(role.weaponChoices.indices, id: \.self) { index in
                                Text("• Choice \(index + 1): \(role.weaponChoices[index].joined(separator: " or "))")
                                    .font(.subheadline)
                            }
                        }
                        
                        Text("Equipment:")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                        
                        ForEach(role.equipment, id: \.self) { equipment in
                            Text("• \(equipment)")
                                .font(.subheadline)
                        }
                        
                        if !role.equipmentChoices.isEmpty {
                            Text("Equipment Choices:")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                            
                            ForEach(role.equipmentChoices.indices, id: \.self) { index in
                                Text("• Choice \(index + 1): \(role.equipmentChoices[index].joined(separator: " or "))")
                                    .font(.subheadline)
                            }
                        }
                    }
                }
                .frame(maxHeight: 400)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(8)
            }
        }
    }
}

struct CompletionStage: View {
    @Binding var character: ImperiumCharacter
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Character Creation Complete")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("Your character has been created! You can now review and modify their details in the character sheet.")
                .font(.caption)
                .foregroundColor(.secondary)
            
            VStack(alignment: .leading, spacing: 12) {
                Text("Character Summary")
                    .font(.headline)
                
                if !character.name.isEmpty {
                    Text("Name: \(character.name)")
                        .font(.subheadline)
                }
                
                if !character.campaign.isEmpty {
                    Text("Campaign: \(character.campaign)")
                        .font(.subheadline)
                }
                
                if !character.homeworld.isEmpty {
                    Text("Origin: \(character.homeworld)")
                        .font(.subheadline)
                }
                
                if !character.faction.isEmpty {
                    Text("Faction: \(character.faction)")
                        .font(.subheadline)
                }
                
                if !character.role.isEmpty {
                    Text("Role: \(character.role)")
                        .font(.subheadline)
                }
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(8)
            
            Text("The character sheet will allow you to:")
                .font(.headline)
            
            VStack(alignment: .leading, spacing: 8) {
                Text("• Modify characteristics and skill advances")
                Text("• Select specific talents from role choices")
                Text("• Choose equipment from faction and role options")
                Text("• Track reputation with factions")
                Text("• Manage weapons and gear")
                Text("• Record psychic powers (if applicable)")
            }
            .font(.subheadline)
            .foregroundColor(.secondary)
        }
    }
}

#Preview {
    CharacterCreationWizard(store: CharacterStore())
}