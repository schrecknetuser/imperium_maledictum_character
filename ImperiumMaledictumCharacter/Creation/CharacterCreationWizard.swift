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
    @State private var showingCharacterPreview = false
    
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
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingCharacterPreview = true
                    } label: {
                        Image(systemName: "person.text.rectangle")
                    }
                }
            }
            .sheet(isPresented: $showingCharacterPreview) {
                CharacterPreviewSheet(character: character)
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
            if character.faction.isEmpty {
                return false
            }
            // Check if a talent choice is required and selected
            if let faction = FactionDefinitions.getFaction(by: character.faction) {
                if !faction.talentChoices.isEmpty && character.selectedFactionTalentChoice.isEmpty {
                    return false
                }
            }
            return true
        case 4: // Role
            return !character.role.isEmpty
        case 5: // Complete
            return true
        default:
            return false
        }
    }
    
    private func canCompleteCreation() -> Bool {
        let basicRequirementsPass = !character.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
               !character.faction.isEmpty &&
               !character.role.isEmpty &&
               !character.homeworld.isEmpty
        
        if !basicRequirementsPass {
            return false
        }
        
        // Check if a talent choice is required and selected for the faction
        if let faction = FactionDefinitions.getFaction(by: character.faction) {
            if !faction.talentChoices.isEmpty && character.selectedFactionTalentChoice.isEmpty {
                return false
            }
        }
        
        return true
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
                
                Text("Enter your character's basic information. Only the character name is required to proceed.")
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
                
                VStack(alignment: .leading, spacing: 12) {
                    Text("Short-term Goal")
                        .font(.headline)
                    TextEditor(text: $character.shortTermGoal)
                        .frame(minHeight: 60)
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color(.systemGray4), lineWidth: 1)
                        )
                        .overlay(
                            Group {
                                if character.shortTermGoal.isEmpty {
                                    Text("What does your character want to achieve soon? (optional)")
                                        .foregroundColor(.secondary)
                                        .allowsHitTesting(false)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 8)
                                }
                            }, alignment: .topLeading
                        )
                }
                
                VStack(alignment: .leading, spacing: 12) {
                    Text("Long-term Goal")
                        .font(.headline)
                    TextEditor(text: $character.longTermGoal)
                        .frame(minHeight: 60)
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color(.systemGray4), lineWidth: 1)
                        )
                        .overlay(
                            Group {
                                if character.longTermGoal.isEmpty {
                                    Text("What are your character's ultimate aspirations? (optional)")
                                        .foregroundColor(.secondary)
                                        .allowsHitTesting(false)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 8)
                                }
                            }, alignment: .topLeading
                        )
                }
                
                VStack(alignment: .leading, spacing: 12) {
                    Text("Character Description")
                        .font(.headline)
                    TextEditor(text: $character.characterDescription)
                        .frame(minHeight: 80)
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color(.systemGray4), lineWidth: 1)
                        )
                        .overlay(
                            Group {
                                if character.characterDescription.isEmpty {
                                    Text("Describe your character's appearance, personality, background... (optional)")
                                        .foregroundColor(.secondary)
                                        .allowsHitTesting(false)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 8)
                                }
                            }, alignment: .topLeading
                        )
                }
                
                VStack(alignment: .leading, spacing: 12) {
                    Text("Notes")
                        .font(.headline)
                    TextEditor(text: $character.notes)
                        .frame(minHeight: 80)
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color(.systemGray4), lineWidth: 1)
                        )
                        .overlay(
                            Group {
                                if character.notes.isEmpty {
                                    Text("Additional notes about your character (optional)")
                                        .foregroundColor(.secondary)
                                        .allowsHitTesting(false)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 8)
                                }
                            }, alignment: .topLeading
                        )
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
                    name: CharacteristicNames.perception,
                    baseValue: 20,
                    allocatedPoints: binding(for: CharacteristicNames.perception),
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
        print("DEBUG: initializeAllocatedPoints() called")
        
        // Load user allocations from character
        allocatedPoints = character.userCharacteristicAllocationsDict
        
        // If no allocations stored yet, initialize with current allocations
        if allocatedPoints.isEmpty {
            let characteristics = character.characteristics
            for name in CharacteristicNames.allCharacteristics {
                let characteristic = characteristics[name] ?? Characteristic(name: name, initialValue: 20, advances: 0)
                
                // Calculate how much is user allocation vs bonuses
                let currentValue = characteristic.initialValue
                let totalBonuses = getAppliedBonusesForCharacteristic(name)
                
                // User allocation is what's left after removing base and bonuses
                let userAllocation = max(0, currentValue - 20 - totalBonuses)
                allocatedPoints[name] = userAllocation
                
                print("DEBUG: \(name) - currentValue: \(currentValue), totalBonuses: \(totalBonuses), userAllocation: \(userAllocation)")
            }
            
            // Save the initialized allocations
            character.userCharacteristicAllocationsDict = allocatedPoints
        } else {
            print("DEBUG: Loaded existing user allocations: \(allocatedPoints)")
        }
        
        updateRemainingPoints()
        print("DEBUG: initializeAllocatedPoints() completed")
    }
    
    private func saveCharacteristicsToCharacter() {
        print("DEBUG: saveCharacteristicsToCharacter() called")
        
        // Save the user's allocations to the character
        character.userCharacteristicAllocationsDict = allocatedPoints
        
        // Recalculate all characteristics based on allocations + bonuses
        character.recalculateCharacteristics()
        
        print("DEBUG: saveCharacteristicsToCharacter() completed - user allocations saved and characteristics recalculated")
    }
    
    private func getAppliedBonusesForCharacteristic(_ characteristicName: String) -> Int {
        var totalBonuses = 0
        
        // Origin bonuses
        if !character.homeworld.isEmpty, let origin = OriginDefinitions.getOrigin(by: character.homeworld) {
            // Mandatory bonus
            if origin.mandatoryBonus.characteristic == characteristicName {
                totalBonuses += origin.mandatoryBonus.bonus
                print("DEBUG: Adding origin mandatory bonus \(origin.mandatoryBonus.bonus) to \(characteristicName)")
            }
            // Choice bonus
            if character.selectedOriginChoice == characteristicName {
                if let choiceBonus = origin.choiceBonus.first(where: { $0.characteristic == characteristicName }) {
                    totalBonuses += choiceBonus.bonus
                    print("DEBUG: Adding origin choice bonus \(choiceBonus.bonus) to \(characteristicName)")
                }
            }
        }
        
        // Faction bonuses
        if !character.faction.isEmpty, let faction = FactionDefinitions.getFaction(by: character.faction) {
            // Mandatory bonus
            if faction.mandatoryBonus.characteristic == characteristicName {
                totalBonuses += faction.mandatoryBonus.bonus
                print("DEBUG: Adding faction mandatory bonus \(faction.mandatoryBonus.bonus) to \(characteristicName)")
            }
            // Choice bonus
            if character.selectedFactionChoice == characteristicName {
                if let choiceBonus = faction.choiceBonus.first(where: { $0.characteristic == characteristicName }) {
                    totalBonuses += choiceBonus.bonus
                    print("DEBUG: Adding faction choice bonus \(choiceBonus.bonus) to \(characteristicName)")
                }
            }
        }
        
        print("DEBUG: Total bonuses for \(characteristicName): \(totalBonuses), originChoice: '\(character.selectedOriginChoice)', factionChoice: '\(character.selectedFactionChoice)'")
        return totalBonuses
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
                .onChange(of: character.homeworld) { oldValue, newValue in
                    // Clear selection when origin changes
                    selectedChoice = ""
                    
                    // Clear tracking for old origin if it was different
                    if !oldValue.isEmpty && oldValue != newValue {
                        var appliedBonuses = character.appliedOriginBonusesTracker
                        appliedBonuses[oldValue] = false
                        character.appliedOriginBonusesTracker = appliedBonuses
                        
                        // Remove old origin bonuses if any
                        if let oldOrigin = OriginDefinitions.getOrigin(by: oldValue) {
                            removeOriginBonuses(origin: oldOrigin)
                        }
                    }
                    
                    // Apply bonuses for new origin
                    applyOriginBonuses()
                }
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
                                    applyOriginBonuses()
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
                        
                        ForEach(Array(origin.grantedEquipment.enumerated()), id: \.offset) { index, equipment in
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
        .onAppear {
            initializeOriginSelections()
        }
        .onDisappear {
            saveOriginSelectionsToCharacter()
        }
    }
    
    private func initializeOriginSelections() {
        print("DEBUG: initializeOriginSelections() called")
        print("DEBUG: selectedOrigin: \(selectedOrigin?.name ?? "nil")")
        print("DEBUG: character.selectedOriginChoice: '\(character.selectedOriginChoice)'")
        
        // Initialize from existing character data if available
        if selectedOrigin != nil {
            // Restore the previously selected choice from stored data
            selectedChoice = character.selectedOriginChoice
            print("DEBUG: Restored selectedChoice to: '\(selectedChoice)'")
        } else {
            print("DEBUG: No selected origin, keeping selectedChoice empty")
        }
    }
    
    private func applyOriginBonuses() {
        print("DEBUG: applyOriginBonuses() called with selectedChoice: '\(selectedChoice)'")
        guard let origin = selectedOrigin else { 
            print("DEBUG: No origin selected, returning")
            return 
        }
        
        let originKey = origin.name
        var appliedBonuses = character.appliedOriginBonusesTracker
        
        // Always clear and reapply bonuses to handle selection changes
        // First, remove any previously applied bonuses for this origin
        if appliedBonuses[originKey] == true {
            print("DEBUG: Removing previous origin bonuses for: \(originKey)")
            removeOriginBonuses(origin: origin)
        }
        
        // Mark this origin as having bonuses applied
        appliedBonuses[originKey] = true
        character.appliedOriginBonusesTracker = appliedBonuses
        
        // Save the selected choice
        character.selectedOriginChoice = selectedChoice
        print("DEBUG: Set character.selectedOriginChoice to: '\(character.selectedOriginChoice)'")
        
        // Recalculate characteristics to apply the bonuses
        character.recalculateCharacteristics()
        print("DEBUG: applyOriginBonuses() completed")
    }
    
    private func removeOriginBonuses(origin: Origin) {
        print("DEBUG: removeOriginBonuses() called")
        print("DEBUG: Before clearing - character.selectedOriginChoice: '\(character.selectedOriginChoice)'")
        
        // Clear the selected choice when removing bonuses
        character.selectedOriginChoice = ""
        print("DEBUG: After clearing - character.selectedOriginChoice: '\(character.selectedOriginChoice)'")
        
        // Recalculate characteristics without the bonuses
        character.recalculateCharacteristics()
        print("DEBUG: removeOriginBonuses() completed")
    }
    
    private func saveOriginSelectionsToCharacter() {
        print("DEBUG: saveOriginSelectionsToCharacter() called")
        print("DEBUG: selectedChoice: '\(selectedChoice)'")
        print("DEBUG: character.selectedOriginChoice before apply: '\(character.selectedOriginChoice)'")
        
        guard let origin = selectedOrigin else { 
            print("DEBUG: No origin selected in saveOriginSelectionsToCharacter()")
            return 
        }
        
        // Apply bonuses one final time to ensure they're saved
        applyOriginBonuses()
        
        print("DEBUG: character.selectedOriginChoice after apply: '\(character.selectedOriginChoice)'")
        
        // Add granted equipment to equipment list
        var equipmentList = character.equipmentList
        for equipment in origin.grantedEquipment {
            if !equipmentList.contains(where: { $0.name == equipment }) {
                if let template = EquipmentTemplateDefinitions.getTemplate(for: equipment) {
                    equipmentList.append(template.createEquipment())
                } else {
                    // Fallback: create basic equipment object if template not found
                    let basicEquipment = Equipment(name: equipment, encumbrance: 1, cost: 0, availability: "Common")
                    basicEquipment.equipmentDescription = "Origin granted equipment"
                    equipmentList.append(basicEquipment)
                }
            }
        }
        character.equipmentList = equipmentList
        print("DEBUG: saveOriginSelectionsToCharacter() completed")
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
                .onChange(of: character.faction) { oldValue, newValue in
                    // Clear selections when faction changes
                    selectedChoice = ""
                    
                    // Clear tracking for old faction if it was different
                    if !oldValue.isEmpty && oldValue != newValue {
                        var appliedBonuses = character.appliedFactionBonusesTracker
                        appliedBonuses[oldValue] = false
                        character.appliedFactionBonusesTracker = appliedBonuses
                        
                        // Remove old faction bonuses if any
                        if let oldFaction = FactionDefinitions.getFaction(by: oldValue) {
                            removeFactionBonuses(faction: oldFaction)
                        }
                    }
                    
                    // Reset and apply for new faction
                    resetFactionSelections()
                    applyFactionBonuses()
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
                                            applyFactionBonuses()
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
                            
                            if !faction.talentChoices.isEmpty {
                                Text("Talent Choice (select one):")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                
                                VStack(alignment: .leading, spacing: 8) {
                                    ForEach(faction.talentChoices.indices, id: \.self) { index in
                                        let choice = faction.talentChoices[index]
                                        Button(action: {
                                            character.selectedFactionTalentChoice = choice.name
                                        }) {
                                            HStack(alignment: .top, spacing: 8) {
                                                Image(systemName: character.selectedFactionTalentChoice == choice.name ? "checkmark.circle.fill" : "circle")
                                                    .foregroundColor(character.selectedFactionTalentChoice == choice.name ? .blue : .gray)
                                                
                                                VStack(alignment: .leading, spacing: 2) {
                                                    Text(choice.name)
                                                        .font(.subheadline)
                                                        .fontWeight(.medium)
                                                    
                                                    Text(choice.talents.joined(separator: ", "))
                                                        .font(.caption)
                                                        .foregroundColor(.secondary)
                                                }
                                                
                                                Spacer()
                                            }
                                        }
                                        .buttonStyle(.plain)
                                        .foregroundColor(character.selectedFactionTalentChoice == choice.name ? .blue : .primary)
                                    }
                                }
                            }
                            
                            Text("Equipment:")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                            
                            ForEach(Array(faction.equipment.enumerated()), id: \.offset) { index, equipment in
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
        print("DEBUG: initializeFactionSelections() called")
        print("DEBUG: selectedFaction: \(selectedFaction?.name ?? "nil")")
        print("DEBUG: character.selectedFactionChoice: '\(character.selectedFactionChoice)'")
        
        guard let faction = selectedFaction else { 
            print("DEBUG: No faction selected, returning")
            return 
        }
        
        // Restore the previously selected choice from stored data
        selectedChoice = character.selectedFactionChoice
        print("DEBUG: Restored selectedChoice to: '\(selectedChoice)'")
        
        // Always reset to current character state when appearing
        let existingAdvances = character.factionSkillAdvances
        skillAdvancesDistribution = [:]
        
        // Initialize skill advances distribution from existing character data
        for skill in faction.skillAdvances {
            skillAdvancesDistribution[skill] = existingAdvances[skill] ?? 0
        }
        
        // Initialize talent choice from existing character data if it's valid for this faction
        if !faction.talentChoices.isEmpty {
            let validChoiceNames = faction.talentChoices.map { $0.name }
            if validChoiceNames.contains(character.selectedFactionTalentChoice) {
                // Keep the existing choice if it's valid
            } else {
                // Reset if invalid or empty
                character.selectedFactionTalentChoice = ""
            }
        }
        
        hasInitialized = true
        updateRemainingSkillAdvances()
        print("DEBUG: initializeFactionSelections() completed")
    }
    
    private func resetFactionSelections() {
        selectedChoice = ""
        skillAdvancesDistribution = [:]
        remainingSkillAdvances = 5
        hasInitialized = false
        character.selectedFactionTalentChoice = ""
        if selectedFaction != nil {
            initializeFactionSelections()
        }
    }
    
    private func saveFactionSelectionsToCharacter() {
        print("DEBUG: saveFactionSelectionsToCharacter() called")
        print("DEBUG: selectedChoice: '\(selectedChoice)'")
        print("DEBUG: character.selectedFactionChoice before apply: '\(character.selectedFactionChoice)'")
        
        guard let faction = selectedFaction else { 
            print("DEBUG: No faction selected in saveFactionSelectionsToCharacter()")
            return 
        }
        
        // Don't duplicate - this will be handled properly when we implement it fully
        // For now, just store the direct values to avoid accumulation
        var currentAdvances: [String: Int] = [:]
        for (skill, advances) in skillAdvancesDistribution {
            currentAdvances[skill] = advances
        }
        // Store faction-specific advances separately to avoid duplication
        character.factionSkillAdvances = currentAdvances
        
        // Apply characteristic bonuses
        applyFactionBonuses()
        
        print("DEBUG: character.selectedFactionChoice after apply: '\(character.selectedFactionChoice)'")
        
        // Add faction talents
        var allTalents = character.talentNames
        
        // Add automatic faction talents
        for talent in faction.talents {
            if !allTalents.contains(talent) {
                allTalents.append(talent)
            }
        }
        
        // Add talents from selected choice
        if !character.selectedFactionTalentChoice.isEmpty {
            if let selectedChoice = faction.talentChoices.first(where: { $0.name == character.selectedFactionTalentChoice }) {
                for talent in selectedChoice.talents {
                    if !allTalents.contains(talent) {
                        allTalents.append(talent)
                    }
                }
            }
        }
        
        character.talentNames = allTalents
        
        // Add faction equipment to equipment list
        var equipmentList = character.equipmentList
        for equipment in faction.equipment {
            if !equipmentList.contains(where: { $0.name == equipment }) {
                if let template = EquipmentTemplateDefinitions.getTemplate(for: equipment) {
                    equipmentList.append(template.createEquipment())
                } else {
                    // Fallback: create basic equipment object if template not found
                    let basicEquipment = Equipment(name: equipment, encumbrance: 1, cost: 0, availability: "Common")
                    basicEquipment.equipmentDescription = "Faction granted equipment"
                    equipmentList.append(basicEquipment)
                }
            }
        }
        character.equipmentList = equipmentList
        
        // Set starting solars
        character.solars = faction.solars
        print("DEBUG: saveFactionSelectionsToCharacter() completed")
    }
    
    private func applyFactionBonuses() {
        print("DEBUG: applyFactionBonuses() called with selectedChoice: '\(selectedChoice)'")
        guard let faction = selectedFaction else { 
            print("DEBUG: No faction selected, returning")
            return 
        }
        
        let factionKey = faction.name
        var appliedBonuses = character.appliedFactionBonusesTracker
        
        // Always clear and reapply bonuses to handle selection changes
        // First, remove any previously applied bonuses for this faction
        if appliedBonuses[factionKey] == true {
            print("DEBUG: Removing previous faction bonuses for: \(factionKey)")
            removeFactionBonuses(faction: faction)
        }
        
        // Apply reputation influence bonus
        var reputations = character.reputations
        let influenceFaction = faction.influenceBonus
        
        // Check if there's already a reputation entry for this faction
        if let index = reputations.firstIndex(where: { $0.faction == influenceFaction && $0.individual.isEmpty }) {
            // Update existing reputation by setting it to 1 (don't accumulate)
            reputations[index].value = 1
        } else {
            // Create new reputation entry with +1 value
            reputations.append(Reputation(faction: influenceFaction, individual: "", value: 1))
        }
        character.reputations = reputations
        
        // Mark this faction as having bonuses applied
        appliedBonuses[factionKey] = true
        character.appliedFactionBonusesTracker = appliedBonuses
        
        // Save the selected choice
        character.selectedFactionChoice = selectedChoice
        print("DEBUG: Set character.selectedFactionChoice to: '\(character.selectedFactionChoice)'")
        
        // Recalculate characteristics to apply the bonuses
        character.recalculateCharacteristics()
        print("DEBUG: applyFactionBonuses() completed")
    }
    
    private func removeFactionBonuses(faction: Faction) {
        print("DEBUG: removeFactionBonuses() called")
        print("DEBUG: Before clearing - character.selectedFactionChoice: '\(character.selectedFactionChoice)'")
        
        // Clear the selected choice when removing bonuses
        character.selectedFactionChoice = ""
        print("DEBUG: After clearing - character.selectedFactionChoice: '\(character.selectedFactionChoice)'")
        
        // Remove reputation influence bonus
        var reputations = character.reputations
        reputations.removeAll { $0.faction == faction.influenceBonus && $0.individual.isEmpty }
        character.reputations = reputations
        
        // Recalculate characteristics without the bonuses
        character.recalculateCharacteristics()
        print("DEBUG: removeFactionBonuses() completed")
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
                .frame(maxWidth: .infinity, alignment: .leading)
            
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
            .frame(maxWidth: .infinity)
        }
        .padding(8)
        .background(Color(.systemGray6))
        .cornerRadius(6)
        .frame(maxWidth: .infinity)
    }
}

struct AnySpecializationField: View {
    let skillName: String
    @Binding var advances: Int
    @Binding var customSpecialization: String
    let onAdvancesChanged: () -> Void
    let onSpecializationChanged: (String) -> Void
    
    private var extractedSkillName: String {
        // Extract skill name from "Any (Skill)" format
        if skillName.hasPrefix("Any (") && skillName.hasSuffix(")") {
            return String(skillName.dropFirst(5).dropLast(1))
        }
        return skillName
    }
    
    private var availableSpecializations: [String] {
        return SkillSpecializations.getSpecializations(for: extractedSkillName)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Any (\(extractedSkillName))")
                .font(.subheadline)
                .fontWeight(.medium)
            
            Picker("Select specialization", selection: $customSpecialization) {
                Text("Choose...").tag("")
                ForEach(availableSpecializations, id: \.self) { specialization in
                    Text(specialization).tag(specialization)
                }
            }
            .pickerStyle(MenuPickerStyle())
            .onChange(of: customSpecialization) { newValue in
                onSpecializationChanged(newValue)
            }
            
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
                .disabled(advances <= 0 || customSpecialization.isEmpty)
                
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
                .disabled(customSpecialization.isEmpty)
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
    @State private var autoGrantedRoleTalents: Set<String> = []
    @State private var skillAdvancesDistribution: [String: Int] = [:]
    @State private var remainingSkillAdvances: Int = 0
    @State private var specializationAdvancesDistribution: [String: Int] = [:]
    @State private var remainingSpecializationAdvances: Int = 0
    @State private var customSpecializations: [String: String] = [:] // Maps "Any (Skill)" to custom name
    @State private var selectedWeapons: [String] = []
    @State private var selectedEquipment: [String] = []
    
    var selectedRole: Role? {
        return RoleDefinitions.getRole(by: character.role)
    }
    
    var allFactionTalents: [String] {
        let faction = FactionDefinitions.getFaction(by: character.faction)
        var talents = faction?.talents ?? []
        
        // Add talents from selected faction talent choice
        if !character.selectedFactionTalentChoice.isEmpty,
           let selectedChoice = faction?.talentChoices.first(where: { $0.name == character.selectedFactionTalentChoice }) {
            talents.append(contentsOf: selectedChoice.talents)
        }
        
        return talents
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
                                        alreadyOwned: allFactionTalents.contains(talent) || isAutoGrantedByRole(talent, role: role),
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
                                    GridItem(.flexible()),
                                    GridItem(.flexible())
                                ], spacing: 8) {
                                    ForEach(role.specializationAdvances, id: \.self) { specialization in
                                        if specialization.hasPrefix("Any (") {
                                            AnySpecializationField(
                                                skillName: specialization,
                                                advances: specializationBinding(for: specialization),
                                                customSpecialization: customSpecializationBinding(for: specialization),
                                                onAdvancesChanged: updateRemainingSpecializationAdvances,
                                                onSpecializationChanged: { newName in
                                                    updateCustomSpecialization(specialization, newName: newName)
                                                }
                                            )
                                        } else {
                                            SkillAdvanceField(
                                                skillName: specialization,
                                                advances: specializationBinding(for: specialization),
                                                onAdvancesChanged: updateRemainingSpecializationAdvances
                                            )
                                        }
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
                                                ForEach(Array(equipmentOptions.enumerated()), id: \.offset) { equipmentIndex, equipment in
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
                            
                            ForEach(Array(role.equipment.enumerated()), id: \.offset) { index, equipment in
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
    
    private func customSpecializationBinding(for specialization: String) -> Binding<String> {
        return Binding(
            get: { customSpecializations[specialization] ?? "" },
            set: { newValue in
                customSpecializations[specialization] = newValue
                // Save changes immediately to ensure persistence
                saveRoleSelectionsToCharacter()
            }
        )
    }
    
    private func updateCustomSpecialization(_ anySpecialization: String, newName: String) {
        customSpecializations[anySpecialization] = newName
        // Save changes immediately to ensure persistence
        saveRoleSelectionsToCharacter()
    }
    
    // Helper function to determine if a talent is auto-granted by a role
    private func isAutoGrantedByRole(_ talent: String, role: Role) -> Bool {
        return role.name == "Mystic" && talent == "Psyker"
    }
    
    private func initializeRoleSelections() {
        guard let role = selectedRole else { return }
        
        // Initialize weapon choices array and try to restore previous selections
        selectedWeapons = Array(repeating: "", count: role.weaponChoices.count)
        let existingWeaponNames = character.weaponList.map { $0.name }
        for (choiceIndex, weaponOptions) in role.weaponChoices.enumerated() {
            for weapon in weaponOptions {
                if existingWeaponNames.contains(weapon) {
                    selectedWeapons[choiceIndex] = weapon
                    break // Only select one weapon per choice
                }
            }
        }
        
        // Initialize equipment choices array and try to restore previous selections
        selectedEquipment = Array(repeating: "", count: role.equipmentChoices.count)
        let existingEquipmentNames = character.equipmentList.map { $0.name }
        for (choiceIndex, equipmentOptions) in role.equipmentChoices.enumerated() {
            for equipment in equipmentOptions {
                if existingEquipmentNames.contains(equipment) {
                    selectedEquipment[choiceIndex] = equipment
                    break // Only select one equipment per choice
                }
            }
        }
        
        // Initialize skill advances from existing character data
        skillAdvancesDistribution = [:]
        let existingAdvances = character.skillAdvances
        for skill in role.skillAdvances {
            skillAdvancesDistribution[skill] = existingAdvances[skill] ?? 0
        }
        remainingSkillAdvances = role.skillAdvanceCount
        updateRemainingSkillAdvances()
        
        // Initialize specialization advances
        specializationAdvancesDistribution = [:]
        for specialization in role.specializationAdvances {
            specializationAdvancesDistribution[specialization] = 0
        }
        remainingSpecializationAdvances = role.specializationAdvanceCount
        updateRemainingSpecializationAdvances()
        
        // Get all faction-granted talents (including from talent choices)
        // Use the computed property to ensure consistency with UI
        
        // Get auto-granted role talents (like Psyker for Mystic)
        var autoGrantedRoleTalentsList: [String] = []
        if role.name == "Mystic" {
            autoGrantedRoleTalentsList.append("Psyker")
            if !character.talentNames.contains("Psyker") {
                var updatedTalents = character.talentNames
                updatedTalents.append("Psyker")
                character.talentNames = updatedTalents
            }
        }
        autoGrantedRoleTalents = Set(autoGrantedRoleTalentsList)
        
        // Initialize selected talents from character, excluding faction-granted AND auto-granted role talents
        let filteredTalents = character.talentNames.filter { talent in
            let inRoleChoices = role.talentChoices.contains(talent)
            let inFactionTalents = allFactionTalents.contains(talent)
            let inAutoGranted = isAutoGrantedByRole(talent, role: role)
            
            return inRoleChoices && !inFactionTalents && !inAutoGranted
        }
        selectedTalents = Set(filteredTalents)
    }
    
    private func resetRoleSelections() {
        selectedTalents = []
        autoGrantedRoleTalents = []
        skillAdvancesDistribution = [:]
        specializationAdvancesDistribution = [:]
        customSpecializations = [:]
        selectedWeapons = []
        selectedEquipment = []
        remainingSkillAdvances = 0
        remainingSpecializationAdvances = 0
        
        if selectedRole != nil {
            initializeRoleSelections()
        }
    }
    
    private func saveRoleSelectionsToCharacter() {
        guard let role = selectedRole else { return }
        
        // Save skill advances (replace, don't add to avoid duplication)
        var currentAdvances = character.skillAdvances
        for (skill, advances) in skillAdvancesDistribution {
            currentAdvances[skill] = advances // Replace instead of adding
        }
        character.skillAdvances = currentAdvances
        
        // Save specialization advances with custom names for "Any" specializations
        for (specialization, advances) in specializationAdvancesDistribution {
            if advances > 0 {
                if specialization.hasPrefix("Any (") {
                    // Use custom name if provided
                    if let customName = customSpecializations[specialization], !customName.isEmpty {
                        // Extract skill name from "Any (Skill)" format
                        let skillName = String(specialization.dropFirst(5).dropLast(1)) // Remove "Any (" and ")"
                        // Save with new system
                        character.setSpecializationAdvances(specialization: customName, skill: skillName, advances: advances)
                    }
                    // Don't save if no custom name provided
                } else {
                    // Check if it's already in composite format or a regular specialization
                    if specialization.contains(" (") && specialization.hasSuffix(")") {
                        // Parse composite format
                        let (specName, skillName) = ImperiumCharacter.parseSpecializationKey(specialization)
                        let finalSkillName = skillName ?? SkillSpecializations.findSkillForSpecialization(specName)
                        character.setSpecializationAdvances(specialization: specName, skill: finalSkillName, advances: advances)
                    } else {
                        // Regular specialization - find its skill
                        let skillName = SkillSpecializations.findSkillForSpecialization(specialization)
                        character.setSpecializationAdvances(specialization: specialization, skill: skillName, advances: advances)
                    }
                }
            }
        }
        
        // Save selected talents (replace to avoid duplication)
        var allTalents = character.talentNames
        
        // Get faction-granted talents to preserve them
        let factionGrantedTalents = Set(allFactionTalents)
        
        // Remove any previously selected role talents to avoid duplication, but preserve auto-granted role talents and faction-granted talents
        let talentsToRemove = allTalents.filter { talent in
            let isAutoGranted = isAutoGrantedByRole(talent, role: role)
            return role.talentChoices.contains(talent) && 
                   !isAutoGranted && 
                   !factionGrantedTalents.contains(talent)
        }
        
        allTalents.removeAll { talent in
            let isAutoGranted = isAutoGrantedByRole(talent, role: role)
            return role.talentChoices.contains(talent) && 
                   !isAutoGranted && 
                   !factionGrantedTalents.contains(talent)
        }
        
        // Add currently selected talents
        for talent in selectedTalents {
            if !allTalents.contains(talent) {
                allTalents.append(talent)
            }
        }
        character.talentNames = allTalents
        
        // Save weapon selections by creating weapon objects from templates
        var weaponList = character.weaponList
        for weapon in selectedWeapons {
            if !weapon.isEmpty {
                // Check if weapon already exists
                if !weaponList.contains(where: { $0.name == weapon }) {
                    // Find weapon template and create weapon object
                    if let template = WeaponTemplateDefinitions.getTemplate(for: weapon) {
                        weaponList.append(template.createWeapon())
                    } else {
                        // Fallback: create basic weapon object if template not found
                        let basicWeapon = Weapon(name: weapon, category: WeaponCategories.melee, specialization: WeaponSpecializations.none, damage: "1", range: WeaponRanges.short, magazine: 0, encumbrance: 1, availability: "Common", cost: 0)
                        weaponList.append(basicWeapon)
                    }
                }
            }
        }
        character.weaponList = weaponList
        
        // Save equipment selections by creating equipment objects from templates
        var equipmentList = character.equipmentList
        for equipment in selectedEquipment {
            if !equipment.isEmpty {
                // Check if equipment already exists
                if !equipmentList.contains(where: { $0.name == equipment }) {
                    // Find equipment template and create equipment object
                    if let template = EquipmentTemplateDefinitions.getTemplate(for: equipment) {
                        equipmentList.append(template.createEquipment())
                    } else {
                        // Fallback: create basic equipment object if template not found
                        let basicEquipment = Equipment(name: equipment, encumbrance: 1, cost: 0, availability: "Common")
                        basicEquipment.equipmentDescription = "Equipment from character creation"
                        equipmentList.append(basicEquipment)
                    }
                }
            }
        }
        
        // Add granted equipment from role
        for equipment in role.equipment {
            if !equipmentList.contains(where: { $0.name == equipment }) {
                if let template = EquipmentTemplateDefinitions.getTemplate(for: equipment) {
                    equipmentList.append(template.createEquipment())
                } else {
                    // Fallback: create basic equipment object if template not found
                    let basicEquipment = Equipment(name: equipment, encumbrance: 1, cost: 0, availability: "Common")
                    basicEquipment.equipmentDescription = "Role granted equipment"
                    equipmentList.append(basicEquipment)
                }
            }
        }
        
        character.equipmentList = equipmentList
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
                // Save changes immediately to ensure persistence
                saveRoleSelectionsToCharacter()
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
    let alreadyOwned: Bool
    let onSelectionChanged: (Bool) -> Void
    
    var body: some View {
        Button(action: {
            if !alreadyOwned {
                if isSelected {
                    onSelectionChanged(false)
                } else if !maxReached {
                    onSelectionChanged(true)
                }
            }
        }) {
            HStack {
                Image(systemName: (isSelected || alreadyOwned) ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(alreadyOwned ? .gray : (isSelected ? .blue : (maxReached ? .gray : .primary)))
                Text(talentName)
                    .font(.caption)
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)
                    .foregroundColor(alreadyOwned ? .gray : (isSelected ? .blue : (maxReached ? .gray : .primary)))
                    .strikethrough(alreadyOwned)
                Spacer()
                if alreadyOwned {
                    Text("Owned")
                        .font(.caption2)
                        .foregroundColor(.gray)
                        .italic()
                }
            }
        }
        .buttonStyle(.plain)
        .padding(8)
        .background(alreadyOwned ? Color.gray.opacity(0.1) : (isSelected ? Color.blue.opacity(0.1) : Color(.systemGray6)))
        .cornerRadius(6)
        .disabled(alreadyOwned || (maxReached && !isSelected))
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

// MARK: - Character Preview Sheet

struct CharacterPreviewSheet: View {
    let character: ImperiumCharacter
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Characteristics Table
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Characteristics")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        VStack(spacing: 0) {
                            // Header row
                            HStack {
                                Text("Char.")
                                    .font(.caption)
                                    .fontWeight(.medium)
                                    .frame(width: 40, alignment: .leading)
                                Text("Base")
                                    .font(.caption)
                                    .fontWeight(.medium)
                                    .frame(width: 40, alignment: .center)
                                Text("Adv.")
                                    .font(.caption)
                                    .fontWeight(.medium)
                                    .frame(width: 40, alignment: .center)
                                Text("Total")
                                    .font(.caption)
                                    .fontWeight(.medium)
                                    .frame(width: 50, alignment: .center)
                                Spacer()
                            }
                            .padding(.horizontal)
                            .padding(.vertical, 8)
                            .background(Color(.systemGray5))
                            
                            ForEach(getCharacteristicsList(), id: \.abbreviation) { characteristic in
                                HStack {
                                    Text(characteristic.abbreviation)
                                        .font(.caption)
                                        .frame(width: 40, alignment: .leading)
                                    Text("\(characteristic.baseValue)")
                                        .font(.caption)
                                        .frame(width: 40, alignment: .center)
                                    Text("\(characteristic.advances)")
                                        .font(.caption)
                                        .frame(width: 40, alignment: .center)
                                    Text("\(characteristic.totalValue)")
                                        .font(.caption)
                                        .fontWeight(.medium)
                                        .frame(width: 50, alignment: .center)
                                    Spacer()
                                }
                                .padding(.horizontal)
                                .padding(.vertical, 6)
                                .background(Color(.systemGray6).opacity(0.5))
                            }
                        }
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                    }
                    
                    // Skills Table
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Skills")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        VStack(spacing: 0) {
                            // Header row
                            HStack {
                                Text("Skill")
                                    .font(.caption)
                                    .fontWeight(.medium)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                Text("Char.")
                                    .font(.caption)
                                    .fontWeight(.medium)
                                    .frame(width: 30, alignment: .center)
                                Text("Adv.")
                                    .font(.caption)
                                    .fontWeight(.medium)
                                    .frame(width: 40, alignment: .center)
                                Text("Total")
                                    .font(.caption)
                                    .fontWeight(.medium)
                                    .frame(width: 35, alignment: .center)
                            }
                            .padding(.horizontal)
                            .padding(.vertical, 8)
                            .background(Color(.systemGray5))
                            
                            ForEach(getSkillsList(), id: \.name) { skill in
                                HStack {
                                    Text(skill.name)
                                        .font(.caption)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                    Text(skill.characteristicAbbreviation)
                                        .font(.caption)
                                        .frame(width: 30, alignment: .center)
                                    Text("\(skill.advances)")
                                        .font(.caption)
                                        .frame(width: 40, alignment: .center)
                                    Text("\(skill.totalValue)")
                                        .font(.caption)
                                        .fontWeight(.medium)
                                        .frame(width: 35, alignment: .center)
                                }
                                .padding(.horizontal)
                                .padding(.vertical, 6)
                                .background(Color(.systemGray6).opacity(0.5))
                            }
                        }
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                    }
                    
                    // Specializations Table
                    if !getSpecializationsList().isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Specializations")
                                .font(.headline)
                                .padding(.horizontal)
                            
                            VStack(spacing: 0) {
                                // Header row
                                HStack {
                                    Text("Specialization")
                                        .font(.caption)
                                        .fontWeight(.medium)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                    Text("Skill")
                                        .font(.caption)
                                        .fontWeight(.medium)
                                        .frame(width: 40, alignment: .center)
                                    Text("Adv.")
                                        .font(.caption)
                                        .fontWeight(.medium)
                                        .frame(width: 40, alignment: .center)
                                    Text("Total")
                                        .font(.caption)
                                        .fontWeight(.medium)
                                        .frame(width: 35, alignment: .center)
                                }
                                .padding(.horizontal)
                                .padding(.vertical, 8)
                                .background(Color(.systemGray5))
                                
                                ForEach(getSpecializationsList(), id: \.name) { specialization in
                                    HStack {
                                        Text(specialization.name)
                                            .font(.caption)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                        Text(specialization.skillName)
                                            .font(.caption)
                                            .frame(width: 40, alignment: .center)
                                        Text("\(specialization.advances)")
                                            .font(.caption)
                                            .frame(width: 40, alignment: .center)
                                        Text("\(specialization.totalValue)")
                                            .font(.caption)
                                            .fontWeight(.medium)
                                            .frame(width: 35, alignment: .center)
                                    }
                                    .padding(.horizontal)
                                    .padding(.vertical, 6)
                                    .background(Color(.systemGray6).opacity(0.5))
                                }
                            }
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Character Preview")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func getCharacteristicsList() -> [CharacteristicRowData] {
        var result: [CharacteristicRowData] = []
        
        let characteristics = character.characteristics
        let characteristicInfo = [
            ("WS", "Weapon Skill", characteristics[CharacteristicNames.weaponSkill] ?? Characteristic(name: CharacteristicNames.weaponSkill, initialValue: 20, advances: 0)),
            ("BS", "Ballistic Skill", characteristics[CharacteristicNames.ballisticSkill] ?? Characteristic(name: CharacteristicNames.ballisticSkill, initialValue: 20, advances: 0)),
            ("Str", "Strength", characteristics[CharacteristicNames.strength] ?? Characteristic(name: CharacteristicNames.strength, initialValue: 20, advances: 0)),
            ("Tgh", "Toughness", characteristics[CharacteristicNames.toughness] ?? Characteristic(name: CharacteristicNames.toughness, initialValue: 20, advances: 0)),
            ("Agi", "Agility", characteristics[CharacteristicNames.agility] ?? Characteristic(name: CharacteristicNames.agility, initialValue: 20, advances: 0)),
            ("Int", "Intelligence", characteristics[CharacteristicNames.intelligence] ?? Characteristic(name: CharacteristicNames.intelligence, initialValue: 20, advances: 0)),
            ("Per", "Perception", characteristics[CharacteristicNames.perception] ?? Characteristic(name: CharacteristicNames.perception, initialValue: 20, advances: 0)),
            ("Wil", "Willpower", characteristics[CharacteristicNames.willpower] ?? Characteristic(name: CharacteristicNames.willpower, initialValue: 20, advances: 0)),
            ("Fel", "Fellowship", characteristics[CharacteristicNames.fellowship] ?? Characteristic(name: CharacteristicNames.fellowship, initialValue: 20, advances: 0))
        ]
        
        for (abbrev, name, characteristic) in characteristicInfo {
            result.append(CharacteristicRowData(
                abbreviation: abbrev,
                name: name,
                baseValue: characteristic.initialValue,
                advances: characteristic.advances,
                totalValue: characteristic.derivedValue
            ))
        }
        
        return result
    }
    
    private func getSkillsList() -> [SkillRowData] {
        var result: [SkillRowData] = []
        
        let skillAdvances = character.skillAdvances
        let factionSkillAdvances = character.factionSkillAdvances
        
        // Define skill-to-characteristic mapping using the game's actual skills
        let skillCharacteristicMap = [
            "Athletics": "Str",
            "Awareness": "Per",
            "Dexterity": "Agi",
            "Discipline": "Wil",
            "Fortitude": "Tgh",
            "Intuition": "Per",
            "Linguistics": "Int",
            "Logic": "Int",
            "Lore": "Int",
            "Medicae": "Int",
            "Melee": "WS",
            "Navigation": "Int",
            "Piloting": "Agi",
            "Presence": "Wil",
            "Psychic Mastery": "Wil",
            "Ranged": "BS",
            "Rapport": "Fel",
            "Reflexes": "Agi",
            "Stealth": "Agi",
            "Tech": "Int"
        ]
        
        // Display ALL skills, not just those with advances
        for skillName in skillCharacteristicMap.keys.sorted() {
            let skillAdvanceCount = skillAdvances[skillName] ?? 0
            let factionAdvanceCount = factionSkillAdvances[skillName] ?? 0
            let totalAdvances = skillAdvanceCount + factionAdvanceCount
            
            let characteristicAbbrev = skillCharacteristicMap[skillName] ?? "Int"
            let characteristicValue = getCharacteristicValue(for: characteristicAbbrev)
            
            result.append(SkillRowData(
                name: skillName,
                characteristicAbbreviation: characteristicAbbrev,
                advances: totalAdvances,
                totalValue: characteristicValue + (totalAdvances * 5)
            ))
        }
        
        return result
    }

    private func getSpecializationsList() -> [SpecializationRowData] {
        var result: [SpecializationRowData] = []
        
        let specializationAdvances = character.specializationAdvances
        
        for (specializationKey, advances) in specializationAdvances {
            if advances > 0 {
                // Parse the composite key to get clean specialization name and skill
                let (cleanSpecializationName, skillName) = ImperiumCharacter.parseSpecializationKey(specializationKey)
                let finalSkillName = skillName ?? SkillSpecializations.findSkillForSpecialization(cleanSpecializationName)
                
                // Calculate total value (skill characteristic + specialization advances * 5)
                let skillCharacteristicMap = [
                    "Athletics": "Str",
                    "Awareness": "Per", 
                    "Dexterity": "Agi",
                    "Discipline": "Wil",
                    "Fortitude": "Tgh",
                    "Intuition": "Per",
                    "Linguistics": "Int",
                    "Logic": "Int",
                    "Lore": "Int",
                    "Medicae": "Int",
                    "Melee": "WS",
                    "Navigation": "Int",
                    "Piloting": "Agi",
                    "Presence": "Wil",
                    "Psychic Mastery": "Wil",
                    "Ranged": "BS",
                    "Rapport": "Fel",
                    "Reflexes": "Agi",
                    "Stealth": "Agi",
                    "Tech": "Int"
                ]
                
                let characteristicAbbrev = skillCharacteristicMap[finalSkillName] ?? "Int"
                let characteristicValue = getCharacteristicValue(for: characteristicAbbrev)
                let skillAdvanceCount = character.skillAdvances[finalSkillName] ?? 0
                let factionAdvanceCount = character.factionSkillAdvances[finalSkillName] ?? 0
                let totalSkillValue = characteristicValue + ((skillAdvanceCount + factionAdvanceCount) * 5)
                let specializationTotalValue = totalSkillValue + (advances * 5)
                
                result.append(SpecializationRowData(
                    name: cleanSpecializationName,
                    skillName: finalSkillName,
                    advances: advances,
                    totalValue: specializationTotalValue
                ))
            }
        }
        
        return result.sorted { $0.name < $1.name }
    }
    
    private func getCharacteristicValue(for abbreviation: String) -> Int {
        let characteristics = character.characteristics
        switch abbreviation {
        case "WS": return characteristics[CharacteristicNames.weaponSkill]?.derivedValue ?? 20
        case "BS": return characteristics[CharacteristicNames.ballisticSkill]?.derivedValue ?? 20
        case "Str": return characteristics[CharacteristicNames.strength]?.derivedValue ?? 20
        case "Tgh": return characteristics[CharacteristicNames.toughness]?.derivedValue ?? 20
        case "Agi": return characteristics[CharacteristicNames.agility]?.derivedValue ?? 20
        case "Int": return characteristics[CharacteristicNames.intelligence]?.derivedValue ?? 20
        case "Per": return characteristics[CharacteristicNames.perception]?.derivedValue ?? 20
        case "Wil": return characteristics[CharacteristicNames.willpower]?.derivedValue ?? 20
        case "Fel": return characteristics[CharacteristicNames.fellowship]?.derivedValue ?? 20
        default: return 20
        }
    }
}

#Preview {
    CharacterCreationWizard(store: CharacterStore())
}

// MARK: - Supporting Data Structures
// Data structures moved to CharacterBase.swift to avoid duplication
