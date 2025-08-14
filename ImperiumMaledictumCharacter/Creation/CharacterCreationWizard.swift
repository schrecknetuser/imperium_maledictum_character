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
            FactionRoleStage(character: $character)
        case 2:
            HomeworldStage(character: $character)
        case 3:
            CharacteristicsStage(character: $character)
        case 4:
            SkillsTalentsStage(character: $character)
        case 5:
            EquipmentStage(character: $character)
        default:
            Text("Unknown stage")
        }
    }
    
    private func canProceedToNextStage() -> Bool {
        switch currentStage {
        case 0: // Basic Info
            return !character.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        case 1: // Faction & Role
            return !character.faction.isEmpty && !character.role.isEmpty
        case 2: // Homeworld
            return !character.homeworld.isEmpty
        case 3, 4, 5: // Characteristics, Skills, Equipment
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
                
                VStack(alignment: .leading, spacing: 12) {
                    Text("Character Name")
                        .font(.headline)
                    TextField("Enter character name", text: $character.name)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                
                VStack(alignment: .leading, spacing: 12) {
                    Text("Player Name")
                        .font(.headline)
                    TextField("Enter player name", text: $character.player)
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

struct FactionRoleStage: View {
    @Binding var character: ImperiumCharacter
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Faction & Role")
                .font(.title2)
                .fontWeight(.bold)
            
            VStack(alignment: .leading, spacing: 12) {
                Text("Faction")
                    .font(.headline)
                
                Picker("Select Faction", selection: $character.faction) {
                    Text("Select a faction...").tag("")
                    ForEach(ImperiumFactions.all, id: \.self) { faction in
                        Text(faction).tag(faction)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            
            VStack(alignment: .leading, spacing: 12) {
                Text("Role")
                    .font(.headline)
                
                let availableRoles = ImperiumRoles.roles(for: character.faction)
                
                if availableRoles.isEmpty {
                    Text("Select a faction first")
                        .foregroundColor(.secondary)
                        .italic()
                } else {
                    Picker("Select Role", selection: $character.role) {
                        Text("Select a role...").tag("")
                        ForEach(availableRoles, id: \.self) { role in
                            Text(role).tag(role)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            
            if !character.faction.isEmpty && !character.role.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Background (Optional)")
                        .font(.headline)
                    TextField("Brief character background", text: $character.background, axis: .vertical)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .lineLimit(3...6)
                }
            }
        }
        .onChange(of: character.faction) { oldValue, newValue in
            if oldValue != newValue {
                character.role = ""
            }
        }
    }
}

struct HomeworldStage: View {
    @Binding var character: ImperiumCharacter
    
    private let homeworlds = [
        "Hive World", "Forge World", "Agri World", "Civilised World", "Death World",
        "Feral World", "Imperial World", "Shrine World", "Voidborn", "Noble Born"
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Homeworld")
                .font(.title2)
                .fontWeight(.bold)
            
            VStack(alignment: .leading, spacing: 12) {
                Text("Origin")
                    .font(.headline)
                
                Picker("Select Homeworld", selection: $character.homeworld) {
                    Text("Select origin...").tag("")
                    ForEach(homeworlds, id: \.self) { world in
                        Text(world).tag(world)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            
            VStack(alignment: .leading, spacing: 12) {
                Text("Goal (Optional)")
                    .font(.headline)
                TextField("Character's primary goal", text: $character.goal, axis: .vertical)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .lineLimit(2...4)
            }
            
            VStack(alignment: .leading, spacing: 12) {
                Text("Nemesis (Optional)")
                    .font(.headline)
                TextField("Character's enemy or obstacle", text: $character.nemesis, axis: .vertical)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .lineLimit(2...4)
            }
        }
    }
}

struct CharacteristicsStage: View {
    @Binding var character: ImperiumCharacter
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Characteristics")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("Base characteristics start at 25. You can adjust them based on your homeworld and role.")
                .font(.caption)
                .foregroundColor(.secondary)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 16) {
                CharacteristicField("Weapon Skill", value: $character.weaponSkill)
                CharacteristicField("Ballistic Skill", value: $character.ballisticSkill)
                CharacteristicField("Strength", value: $character.strength)
                CharacteristicField("Toughness", value: $character.toughness)
                CharacteristicField("Agility", value: $character.agility)
                CharacteristicField("Intelligence", value: $character.intelligence)
                CharacteristicField("Willpower", value: $character.willpower)
                CharacteristicField("Fellowship", value: $character.fellowship)
                CharacteristicField("Influence", value: $character.influence)
            }
        }
    }
}

struct CharacteristicField: View {
    let name: String
    @Binding var value: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(name)
                .font(.headline)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
            
            HStack {
                Button("-") {
                    if value > 10 {
                        value -= 5
                    }
                }
                .buttonStyle(.bordered)
                .disabled(value <= 10)
                
                Spacer()
                
                Text("\(value)")
                    .font(.title2)
                    .fontWeight(.bold)
                    .frame(minWidth: 40)
                
                Spacer()
                
                Button("+") {
                    if value < 60 {
                        value += 5
                    }
                }
                .buttonStyle(.bordered)
                .disabled(value >= 60)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
}

struct SkillsTalentsStage: View {
    @Binding var character: ImperiumCharacter
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Skills & Talents")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("You can add skills and talents now or later from the character sheet.")
                .font(.caption)
                .foregroundColor(.secondary)
            
            VStack(alignment: .leading, spacing: 12) {
                Text("Starting Skills")
                    .font(.headline)
                
                Text("Skills will be determined by your faction and role. You can customize them in the character sheet.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            VStack(alignment: .leading, spacing: 12) {
                Text("Starting Talents")
                    .font(.headline)
                
                Text("Talents will be determined by your background and role. You can add more in the character sheet.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
    }
}

struct EquipmentStage: View {
    @Binding var character: ImperiumCharacter
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Equipment")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("Starting equipment is based on your role and faction. You can modify it in the character sheet.")
                .font(.caption)
                .foregroundColor(.secondary)
            
            VStack(alignment: .leading, spacing: 12) {
                Text("Starting Wealth")
                    .font(.headline)
                
                HStack {
                    Text("Thrones:")
                    Spacer()
                    TextField("0", value: $character.thrones, format: .number)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .frame(width: 100)
                }
            }
            
            VStack(alignment: .leading, spacing: 12) {
                Text("Basic Equipment")
                    .font(.headline)
                
                Text("• Clothing appropriate to role\n• Basic personal items\n• Faction-specific gear")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Text("You can add specific equipment items in the character sheet after creation.")
                .font(.caption)
                .foregroundColor(.secondary)
                .italic()
        }
    }
}

#Preview {
    CharacterCreationWizard(store: CharacterStore())
}