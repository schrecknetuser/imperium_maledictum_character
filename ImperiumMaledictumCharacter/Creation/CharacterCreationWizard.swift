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
            
            Text("Allocate 90 points among your characteristics. Each characteristic starts at 20 and each point increases it by 1. Characteristics can range from 5 to 100.")
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
                GridItem(.flexible(), spacing: 8),
                GridItem(.flexible(), spacing: 8),
                GridItem(.flexible(), spacing: 8)
            ], spacing: 12) {
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
            // Calculate allocated points as (initialValue - 20)
            allocatedPoints[name] = characteristic.initialValue - 20
        }
        updateRemainingPoints()
    }
    
    private func saveCharacteristicsToCharacter() {
        var characteristics = character.characteristics
        for (name, points) in allocatedPoints {
            characteristics[name] = Characteristic(name: name, initialValue: 20 + points, advances: 0)
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
        return baseValue + allocatedPoints
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(name)
                .font(.caption)
                .fontWeight(.medium)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            
            HStack(spacing: 4) {
                Button(action: {
                    allocatedPoints -= 1
                    onPointsChanged()
                }) {
                    Image(systemName: "minus")
                        .font(.caption)
                        .fontWeight(.bold)
                }
                .frame(width: 32, height: 32)
                .background(Color(.systemGray5))
                .foregroundColor(.primary)
                .cornerRadius(6)
                .disabled(finalValue <= 5) // Allow going down to 5 (minimum viable characteristic)
                
                VStack(spacing: 1) {
                    Text("\(finalValue)")
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundColor(finalValue < 20 ? .orange : .primary)
                    Text("(\(allocatedPoints))")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                .frame(minWidth: 40)
                
                Button(action: {
                    allocatedPoints += 1
                    onPointsChanged()
                }) {
                    Image(systemName: "plus")
                        .font(.caption)
                        .fontWeight(.bold)
                }
                .frame(width: 32, height: 32)
                .background(Color(.systemGray5))
                .foregroundColor(.primary)
                .cornerRadius(6)
                .disabled(finalValue >= 100)
            }
        }
        .padding(8)
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
    @State private var skillAdvancesDistribution: [String: Int] = [:]
    @State private var remainingSkillAdvances: Int = 5
    @State private var hasInitialized: Bool = false
    
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
                .onChange(of: character.faction) { _ in
                    resetFactionSelections()
                }
            }
            
            if let faction = selectedFaction {
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        Text(faction.description)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        // Characteristic bonuses section
                        VStack(alignment: .leading, spacing: 8) {
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
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                        
                        // Skill advances section
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text("Skills (5 advances to distribute):")
                                    .font(.headline)
                                Spacer()
                                Text("\(remainingSkillAdvances) remaining")
                                    .font(.subheadline)
                                    .foregroundColor(remainingSkillAdvances < 0 ? .red : .secondary)
                            }
                            
                            LazyVGrid(columns: [
                                GridItem(.flexible()),
                                GridItem(.flexible())
                            ], spacing: 12) {
                                ForEach(faction.skillAdvances, id: \.self) { skill in
                                    SkillAdvanceField(
                                        skillName: skill,
                                        advances: binding(for: skill),
                                        onAdvancesChanged: updateRemainingSkillAdvances
                                    )
                                }
                            }
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                        
                        // Other faction benefits
                        VStack(alignment: .leading, spacing: 8) {
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
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                    }
                }
                .frame(maxHeight: 400)
            }
        }
        .onAppear {
            initializeFactionSelections()
        }
        .onDisappear {
            saveFactionSelectionsToCharacter()
        }
    }
    
    private func initializeFactionSelections() {
        guard let faction = selectedFaction, !hasInitialized else { return }
        
        // Initialize skill advances distribution to zero (fresh start each time)
        for skill in faction.skillAdvances {
            skillAdvancesDistribution[skill] = 0
        }
        hasInitialized = true
        updateRemainingSkillAdvances()
    }
    
    private func resetFactionSelections() {
        selectedChoice = ""
        skillAdvancesDistribution = [:]
        remainingSkillAdvances = 5
        hasInitialized = false
        if selectedFaction != nil {
            initializeFactionSelections()
        }
    }
    
    private func saveFactionSelectionsToCharacter() {
        // Don't duplicate - this will be handled properly when we implement it fully
        // For now, just store the direct values to avoid accumulation
        var currentAdvances: [String: Int] = [:]
        for (skill, advances) in skillAdvancesDistribution {
            currentAdvances[skill] = advances
        }
        // Store faction-specific advances separately to avoid duplication
        character.factionSkillAdvances = currentAdvances
        
        // TODO: Save characteristic bonus choice and other selections
    }
    
    private func binding(for skill: String) -> Binding<Int> {
        return Binding(
            get: { skillAdvancesDistribution[skill] ?? 0 },
            set: { newValue in
                skillAdvancesDistribution[skill] = max(0, newValue)
                updateRemainingSkillAdvances()
            }
        )
    }
    
    private func updateRemainingSkillAdvances() {
        let totalDistributed = skillAdvancesDistribution.values.reduce(0, +)
        remainingSkillAdvances = 5 - totalDistributed
    }
}

struct SkillAdvanceField: View {
    let skillName: String
    @Binding var advances: Int
    let onAdvancesChanged: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(skillName)
                .font(.subheadline)
                .fontWeight(.medium)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
            
            HStack(spacing: 8) {
                Button(action: {
                    if advances > 0 {
                        advances -= 1
                        onAdvancesChanged()
                    }
                }) {
                    Image(systemName: "minus")
                        .font(.caption)
                }
                .frame(width: 30, height: 30)
                .background(Color(.systemGray5))
                .foregroundColor(.primary)
                .cornerRadius(6)
                .disabled(advances <= 0)
                
                Text("\(advances)")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .frame(minWidth: 20)
                
                Button(action: {
                    advances += 1
                    onAdvancesChanged()
                }) {
                    Image(systemName: "plus")
                        .font(.caption)
                }
                .frame(width: 30, height: 30)
                .background(Color(.systemGray5))
                .foregroundColor(.primary)
                .cornerRadius(6)
            }
        }
        .padding(8)
        .background(Color(.systemGray6))
        .cornerRadius(6)
    }
}

struct RoleStage: View {
    @Binding var character: ImperiumCharacter
    @State private var selectedTalents: Set<String> = []
    @State private var skillAdvancesDistribution: [String: Int] = [:]
    @State private var remainingSkillAdvances: Int = 0
    @State private var specializationAdvancesDistribution: [String: Int] = [:]
    @State private var remainingSpecializationAdvances: Int = 0
    @State private var selectedWeapons: [String] = []
    @State private var selectedEquipment: [String] = []
    
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
                .onChange(of: character.role) { _ in
                    resetRoleSelections()
                }
            }
            
            if let role = selectedRole {
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        Text(role.description)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        // Talent selection
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text("Talents (\(role.talentCount) to choose):")
                                    .font(.headline)
                                Spacer()
                                Text("\(selectedTalents.count)/\(role.talentCount)")
                                    .font(.subheadline)
                                    .foregroundColor(selectedTalents.count > role.talentCount ? .red : .secondary)
                            }
                            
                            LazyVGrid(columns: [
                                GridItem(.flexible()),
                                GridItem(.flexible())
                            ], spacing: 8) {
                                ForEach(role.talentChoices, id: \.self) { talent in
                                    TalentSelectionField(
                                        talentName: talent,
                                        isSelected: selectedTalents.contains(talent),
                                        maxReached: selectedTalents.count >= role.talentCount,
                                        onSelectionChanged: { isSelected in
                                            if isSelected {
                                                selectedTalents.insert(talent)
                                            } else {
                                                selectedTalents.remove(talent)
                                            }
                                        }
                                    )
                                }
                            }
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                        
                        // Skill advances
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text("Skills (\(role.skillAdvanceCount) advances):")
                                    .font(.headline)
                                Spacer()
                                Text("\(remainingSkillAdvances) remaining")
                                    .font(.subheadline)
                                    .foregroundColor(remainingSkillAdvances < 0 ? .red : .secondary)
                            }
                            
                            LazyVGrid(columns: [
                                GridItem(.flexible()),
                                GridItem(.flexible())
                            ], spacing: 8) {
                                ForEach(role.skillAdvances, id: \.self) { skill in
                                    SkillAdvanceField(
                                        skillName: skill,
                                        advances: skillBinding(for: skill),
                                        onAdvancesChanged: updateRemainingSkillAdvances
                                    )
                                }
                            }
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                        
                        // Specialization advances
                        if !role.specializationAdvances.isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Text("Specializations (\(role.specializationAdvanceCount) advances):")
                                        .font(.headline)
                                    Spacer()
                                    Text("\(remainingSpecializationAdvances) remaining")
                                        .font(.subheadline)
                                        .foregroundColor(remainingSpecializationAdvances < 0 ? .red : .secondary)
                                }
                                
                                LazyVGrid(columns: [
                                    GridItem(.flexible())
                                ], spacing: 8) {
                                    ForEach(role.specializationAdvances, id: \.self) { specialization in
                                        SkillAdvanceField(
                                            skillName: specialization,
                                            advances: specializationBinding(for: specialization),
                                            onAdvancesChanged: updateRemainingSpecializationAdvances
                                        )
                                    }
                                }
                            }
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                        }
                        
                        // Weapon choices
                        if !role.weaponChoices.isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Weapon Choices:")
                                    .font(.headline)
                                
                                ForEach(role.weaponChoices.indices, id: \.self) { choiceIndex in
                                    let weaponOptions = role.weaponChoices[choiceIndex]
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Choice \(choiceIndex + 1):")
                                            .font(.subheadline)
                                            .fontWeight(.semibold)
                                        
                                        HStack {
                                            ForEach(weaponOptions, id: \.self) { weapon in
                                                Button(action: {
                                                    selectWeapon(weapon, forChoice: choiceIndex)
                                                }) {
                                                    HStack {
                                                        Image(systemName: selectedWeapons.indices.contains(choiceIndex) && selectedWeapons[choiceIndex] == weapon ? "checkmark.circle.fill" : "circle")
                                                        Text(weapon)
                                                            .font(.caption)
                                                    }
                                                }
                                                .buttonStyle(.plain)
                                                .foregroundColor(selectedWeapons.indices.contains(choiceIndex) && selectedWeapons[choiceIndex] == weapon ? .blue : .primary)
                                                .padding(.horizontal, 8)
                                                .padding(.vertical, 4)
                                                .background(Color(.systemGray5))
                                                .cornerRadius(4)
                                            }
                                        }
                                    }
                                }
                            }
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                        }
                        
                        // Equipment choices
                        if !role.equipmentChoices.isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Equipment Choices:")
                                    .font(.headline)
                                
                                ForEach(role.equipmentChoices.indices, id: \.self) { choiceIndex in
                                    let equipmentOptions = role.equipmentChoices[choiceIndex]
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Choice \(choiceIndex + 1):")
                                            .font(.subheadline)
                                            .fontWeight(.semibold)
                                        
                                        ScrollView(.horizontal, showsIndicators: false) {
                                            HStack {
                                                ForEach(equipmentOptions, id: \.self) { equipment in
                                                    Button(action: {
                                                        selectEquipment(equipment, forChoice: choiceIndex)
                                                    }) {
                                                        HStack {
                                                            Image(systemName: selectedEquipment.indices.contains(choiceIndex) && selectedEquipment[choiceIndex] == equipment ? "checkmark.circle.fill" : "circle")
                                                            Text(equipment)
                                                                .font(.caption)
                                                                .lineLimit(1)
                                                        }
                                                    }
                                                    .buttonStyle(.plain)
                                                    .foregroundColor(selectedEquipment.indices.contains(choiceIndex) && selectedEquipment[choiceIndex] == equipment ? .blue : .primary)
                                                    .padding(.horizontal, 8)
                                                    .padding(.vertical, 4)
                                                    .background(Color(.systemGray5))
                                                    .cornerRadius(4)
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                        }
                        
                        // Granted equipment
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Granted Equipment:")
                                .font(.headline)
                            
                            ForEach(role.equipment, id: \.self) { equipment in
                                Text("• \(equipment)")
                                    .font(.subheadline)
                            }
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                    }
                }
                .frame(maxHeight: 500)
            }
        }
        .onAppear {
            initializeRoleSelections()
        }
        .onDisappear {
            saveRoleSelectionsToCharacter()
        }
    }
    
    private func initializeRoleSelections() {
        guard let role = selectedRole else { return }
        
        // Initialize weapon choices array
        selectedWeapons = Array(repeating: "", count: role.weaponChoices.count)
        selectedEquipment = Array(repeating: "", count: role.equipmentChoices.count)
        
        // Initialize skill advances
        let existingAdvances = character.skillAdvances
        for skill in role.skillAdvances {
            skillAdvancesDistribution[skill] = existingAdvances[skill] ?? 0
        }
        remainingSkillAdvances = role.skillAdvanceCount
        updateRemainingSkillAdvances()
        
        // Initialize specialization advances
        for specialization in role.specializationAdvances {
            specializationAdvancesDistribution[specialization] = 0
        }
        remainingSpecializationAdvances = role.specializationAdvanceCount
        updateRemainingSpecializationAdvances()
        
        // Initialize selected talents from character
        selectedTalents = Set(character.talentNames.filter { role.talentChoices.contains($0) })
    }
    
    private func resetRoleSelections() {
        selectedTalents = []
        skillAdvancesDistribution = [:]
        specializationAdvancesDistribution = [:]
        selectedWeapons = []
        selectedEquipment = []
        remainingSkillAdvances = 0
        remainingSpecializationAdvances = 0
        
        if selectedRole != nil {
            initializeRoleSelections()
        }
    }
    
    private func saveRoleSelectionsToCharacter() {
        // Save skill advances
        var currentAdvances = character.skillAdvances
        for (skill, advances) in skillAdvancesDistribution {
            currentAdvances[skill] = (currentAdvances[skill] ?? 0) + advances
        }
        character.skillAdvances = currentAdvances
        
        // Save selected talents
        var currentTalents = character.talentNames
        for talent in selectedTalents {
            if !currentTalents.contains(talent) {
                currentTalents.append(talent)
            }
        }
        character.talentNames = currentTalents
        
        // TODO: Save weapon and equipment selections
        // TODO: Save specialization advances
    }
    
    private func skillBinding(for skill: String) -> Binding<Int> {
        return Binding(
            get: { skillAdvancesDistribution[skill] ?? 0 },
            set: { newValue in
                skillAdvancesDistribution[skill] = max(0, newValue)
                updateRemainingSkillAdvances()
            }
        )
    }
    
    private func specializationBinding(for specialization: String) -> Binding<Int> {
        return Binding(
            get: { specializationAdvancesDistribution[specialization] ?? 0 },
            set: { newValue in
                specializationAdvancesDistribution[specialization] = max(0, newValue)
                updateRemainingSpecializationAdvances()
            }
        )
    }
    
    private func updateRemainingSkillAdvances() {
        guard let role = selectedRole else { return }
        let totalDistributed = skillAdvancesDistribution.values.reduce(0, +)
        remainingSkillAdvances = role.skillAdvanceCount - totalDistributed
    }
    
    private func updateRemainingSpecializationAdvances() {
        guard let role = selectedRole else { return }
        let totalDistributed = specializationAdvancesDistribution.values.reduce(0, +)
        remainingSpecializationAdvances = role.specializationAdvanceCount - totalDistributed
    }
    
    private func selectWeapon(_ weapon: String, forChoice choiceIndex: Int) {
        if selectedWeapons.indices.contains(choiceIndex) {
            selectedWeapons[choiceIndex] = weapon
        }
    }
    
    private func selectEquipment(_ equipment: String, forChoice choiceIndex: Int) {
        if selectedEquipment.indices.contains(choiceIndex) {
            selectedEquipment[choiceIndex] = equipment
        }
    }
}

struct TalentSelectionField: View {
    let talentName: String
    let isSelected: Bool
    let maxReached: Bool
    let onSelectionChanged: (Bool) -> Void
    
    var body: some View {
        Button(action: {
            if isSelected {
                onSelectionChanged(false)
            } else if !maxReached {
                onSelectionChanged(true)
            }
        }) {
            HStack {
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(isSelected ? .blue : (maxReached ? .gray : .primary))
                Text(talentName)
                    .font(.caption)
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)
                    .foregroundColor(isSelected ? .blue : (maxReached ? .gray : .primary))
                Spacer()
            }
        }
        .buttonStyle(.plain)
        .padding(8)
        .background(isSelected ? Color.blue.opacity(0.1) : Color(.systemGray6))
        .cornerRadius(6)
        .disabled(maxReached && !isSelected)
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