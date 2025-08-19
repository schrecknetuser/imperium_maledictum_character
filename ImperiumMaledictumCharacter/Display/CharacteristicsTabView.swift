//
//  CharacteristicsTabView.swift
//  ImperiumMaledictumCharacter
//
//  Created by User on 11.01.2025.
//

import SwiftUI

struct CharacteristicsTab: View {
    let character: any BaseCharacter
    @ObservedObject var store: CharacterStore
    @Binding var isEditMode: Bool
    @State private var showingAddSpecializationSheet = false
    @State private var showingDeleteConfirmation = false
    @State private var specializationToDelete: String = ""
    
    var imperiumCharacter: ImperiumCharacter? {
        return character as? ImperiumCharacter
    }
    
    var body: some View {
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
                                .frame(width: isEditMode ? 80 : 40, alignment: .center)
                            Text("Adv.")
                                .font(.caption)
                                .fontWeight(.medium)
                                .frame(width: isEditMode ? 80 : 40, alignment: .center)
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
                                
                                // Base Value Section
                                if isEditMode {
                                    HStack(spacing: 2) {
                                        Button(action: {
                                            let current = imperiumCharacter?.characteristics[characteristic.name]?.initialValue ?? 20
                                            let binding = getCharacteristicBaseValueBinding(for: characteristic.name)
                                            binding.wrappedValue = max(1, current - 1)
                                        }) {
                                            Image(systemName: "minus")
                                                .font(.caption2)
                                                .fontWeight(.bold)
                                                .foregroundColor(.primary)
                                                .frame(width: 20, height: 20)
                                                .background(Color(.systemGray5))
                                                .cornerRadius(3)
                                        }
                                        .disabled((imperiumCharacter?.characteristics[characteristic.name]?.initialValue ?? 20) <= 1)
                                        
                                        Text("\(characteristic.baseValue)")
                                            .font(.caption)
                                            .frame(minWidth: 25)
                                        
                                        Button(action: {
                                            let current = imperiumCharacter?.characteristics[characteristic.name]?.initialValue ?? 20
                                            let binding = getCharacteristicBaseValueBinding(for: characteristic.name)
                                            binding.wrappedValue = min(100, current + 1)
                                        }) {
                                            Image(systemName: "plus")
                                                .font(.caption2)
                                                .fontWeight(.bold)
                                                .foregroundColor(.primary)
                                                .frame(width: 20, height: 20)
                                                .background(Color(.systemGray5))
                                                .cornerRadius(3)
                                        }
                                        .disabled((imperiumCharacter?.characteristics[characteristic.name]?.initialValue ?? 20) >= 100)
                                    }
                                    .frame(width: 80, alignment: .center)
                                } else {
                                    Text("\(characteristic.baseValue)")
                                        .font(.caption)
                                        .frame(width: 40, alignment: .center)
                                }
                                
                                // Advances Section
                                if isEditMode {
                                    HStack(spacing: 2) {
                                        Button(action: {
                                            let current = imperiumCharacter?.characteristics[characteristic.name]?.advances ?? 0
                                            let binding = getCharacteristicAdvanceBinding(for: characteristic.name)
                                            binding.wrappedValue = max(0, current - 1)
                                        }) {
                                            Image(systemName: "minus")
                                                .font(.caption2)
                                                .fontWeight(.bold)
                                                .foregroundColor(.primary)
                                                .frame(width: 20, height: 20)
                                                .background(Color(.systemGray5))
                                                .cornerRadius(3)
                                        }
                                        .disabled((imperiumCharacter?.characteristics[characteristic.name]?.advances ?? 0) <= 0)
                                        
                                        Text("\(characteristic.advances)")
                                            .font(.caption)
                                            .frame(minWidth: 25)
                                        
                                        Button(action: {
                                            let current = imperiumCharacter?.characteristics[characteristic.name]?.advances ?? 0
                                            let binding = getCharacteristicAdvanceBinding(for: characteristic.name)
                                            binding.wrappedValue = min(20, current + 1)
                                        }) {
                                            Image(systemName: "plus")
                                                .font(.caption2)
                                                .fontWeight(.bold)
                                                .foregroundColor(.primary)
                                                .frame(width: 20, height: 20)
                                                .background(Color(.systemGray5))
                                                .cornerRadius(3)
                                        }
                                        .disabled((imperiumCharacter?.characteristics[characteristic.name]?.advances ?? 0) >= 20)
                                    }
                                    .frame(width: 80, alignment: .center)
                                } else {
                                    Text("\(characteristic.advances)")
                                        .font(.caption)
                                        .frame(width: 40, alignment: .center)
                                }
                                
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
                                .frame(width: 40, alignment: .center)
                            Text("Adv.")
                                .font(.caption)
                                .fontWeight(.medium)
                                .frame(width: 40, alignment: .center)
                            Text("Total")
                                .font(.caption)
                                .fontWeight(.medium)
                                .frame(width: 50, alignment: .center)
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
                                    .frame(width: 40, alignment: .center)
                                
                                if isEditMode {
                                    // Editable dropdown for advances
                                    Picker("Advances", selection: getSkillAdvanceBinding(for: skill.name)) {
                                        ForEach(0...4, id: \.self) { value in
                                            Text("\(value)").tag(value)
                                        }
                                    }
                                    .pickerStyle(MenuPickerStyle())
                                    .frame(width: 40)
                                } else {
                                    Text("\(skill.advances)")
                                        .font(.caption)
                                        .frame(width: 40, alignment: .center)
                                }
                                
                                Text("\(skill.totalValue)")
                                    .font(.caption)
                                    .fontWeight(.medium)
                                    .frame(width: 50, alignment: .center)
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
                                .frame(width: 60, alignment: .center)
                            Text("Adv.")
                                .font(.caption)
                                .fontWeight(.medium)
                                .frame(width: 40, alignment: .center)
                            Text("Total")
                                .font(.caption)
                                .fontWeight(.medium)
                                .frame(width: 50, alignment: .center)
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
                                    .frame(width: 60, alignment: .center)
                                
                                if isEditMode {
                                    // Editable dropdown for advances
                                    Picker("Advances", selection: getSpecializationAdvanceBinding(for: specialization.name)) {
                                        ForEach(0...4, id: \.self) { value in
                                            Text("\(value)").tag(value)
                                        }
                                    }
                                    .pickerStyle(MenuPickerStyle())
                                    .frame(width: 40)
                                    
                                    // Delete button
                                    Button(action: {
                                        specializationToDelete = specialization.name
                                        showingDeleteConfirmation = true
                                    }) {
                                        Image(systemName: "trash")
                                            .font(.caption)
                                            .foregroundColor(.red)
                                    }
                                    .frame(width: 30, height: 30)
                                    .background(Color(.systemGray5))
                                    .cornerRadius(6)
                                } else {
                                    Text("\(specialization.advances)")
                                        .font(.caption)
                                        .frame(width: 40, alignment: .center)
                                }
                                
                                Text("\(specialization.totalValue)")
                                    .font(.caption)
                                    .fontWeight(.medium)
                                    .frame(width: 50, alignment: .center)
                            }
                            .padding(.horizontal)
                            .padding(.vertical, 6)
                            .background(Color(.systemGray6).opacity(0.5))
                        }
                        
                        // Add new specialization button in edit mode
                        if isEditMode {
                            Button(action: {
                                showingAddSpecializationSheet = true
                            }) {
                                HStack {
                                    Image(systemName: "plus")
                                        .font(.caption)
                                    Text("Add Specialization")
                                        .font(.caption)
                                    Spacer()
                                }
                                .padding(.horizontal)
                                .padding(.vertical, 6)
                                .background(Color(.systemBlue).opacity(0.1))
                                .foregroundColor(.blue)
                            }
                        }
                    }
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                }
            }
            .padding()
        }
        .sheet(isPresented: $showingAddSpecializationSheet) {
            if let imperium = imperiumCharacter {
                AddSpecializationSheet(character: imperium, store: store)
            }
        }
        .alert("Delete Specialization", isPresented: $showingDeleteConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                deleteSpecialization(specializationToDelete)
            }
        } message: {
            Text("Are you sure you want to delete the specialization '\(specializationToDelete)'? This action cannot be undone.")
        }
    }
    
    private func getCharacteristicBaseValueBinding(for characteristicName: String) -> Binding<Int> {
        return Binding<Int>(
            get: {
                guard let imperium = imperiumCharacter else { return 20 }
                return imperium.characteristics[characteristicName]?.initialValue ?? 20
            },
            set: { newValue in
                guard let imperium = imperiumCharacter else { return }
                var characteristics = imperium.characteristics
                if var characteristic = characteristics[characteristicName] {
                    characteristic.initialValue = max(1, newValue) // Minimum value of 1
                    characteristics[characteristicName] = characteristic
                    imperium.characteristics = characteristics
                    store.saveChanges()
                }
            }
        )
    }
    
    private func getCharacteristicAdvanceBinding(for characteristicName: String) -> Binding<Int> {
        return Binding<Int>(
            get: {
                guard let imperium = imperiumCharacter else { return 0 }
                return imperium.characteristics[characteristicName]?.advances ?? 0
            },
            set: { newValue in
                guard let imperium = imperiumCharacter else { return }
                var characteristics = imperium.characteristics
                if var characteristic = characteristics[characteristicName] {
                    characteristic.advances = newValue
                    characteristics[characteristicName] = characteristic
                    imperium.characteristics = characteristics
                    store.saveChanges()
                }
            }
        )
    }
    
    private func getSkillAdvanceBinding(for skillName: String) -> Binding<Int> {
        return Binding<Int>(
            get: {
                guard let imperium = imperiumCharacter else { return 0 }
                return imperium.skillAdvances[skillName] ?? 0
            },
            set: { newValue in
                guard let imperium = imperiumCharacter else { return }
                var skillAdvances = imperium.skillAdvances
                skillAdvances[skillName] = newValue
                imperium.skillAdvances = skillAdvances
                store.saveChanges()
            }
        )
    }
    
    private func getSpecializationAdvanceBinding(for specializationName: String) -> Binding<Int> {
        return Binding<Int>(
            get: {
                guard let imperium = imperiumCharacter else { return 0 }
                return imperium.specializationAdvances[specializationName] ?? 0
            },
            set: { newValue in
                guard let imperium = imperiumCharacter else { return }
                var specializationAdvances = imperium.specializationAdvances
                specializationAdvances[specializationName] = newValue
                imperium.specializationAdvances = specializationAdvances
                store.saveChanges()
            }
        )
    }
    
    private func getCharacteristicsList() -> [CharacteristicRowData] {
        var result: [CharacteristicRowData] = []
        
        if let imperium = imperiumCharacter {
            let characteristics = imperium.characteristics
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
        }
        
        return result
    }
    
    private func getSkillsList() -> [SkillRowData] {
        var result: [SkillRowData] = []
        
        if let imperium = imperiumCharacter {
            let skillAdvances = imperium.skillAdvances
            let factionSkillAdvances = imperium.factionSkillAdvances
            
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
                let characteristicValue = getCharacteristicValue(for: characteristicAbbrev, from: imperium)
                
                result.append(SkillRowData(
                    name: skillName,
                    characteristicAbbreviation: characteristicAbbrev,
                    advances: totalAdvances,
                    totalValue: characteristicValue + (totalAdvances * 5)
                ))
            }
        }
        
        return result
    }
    
    private func findSkillForSpecialization(_ specializationName: String) -> String {
        // First try direct lookup
        for (skillName, specializations) in SkillSpecializations.specializations {
            if specializations.contains(specializationName) {
                return skillName
            }
        }
        
        // If not found, try parsing if it has the format "Name (Skill)"
        if let parenRange = specializationName.range(of: " ("),
           specializationName.hasSuffix(")") {
            let skillStart = specializationName.index(parenRange.upperBound, offsetBy: 0)
            let skillEnd = specializationName.index(before: specializationName.endIndex)
            let skillName = String(specializationName[skillStart..<skillEnd])
            
            // Validate that this is a real skill
            if SkillSpecializations.specializations[skillName] != nil {
                return skillName
            }
        }
        
        return "Unknown"
    }

    private func getSpecializationsList() -> [SpecializationRowData] {
        var result: [SpecializationRowData] = []
        
        if let imperium = imperiumCharacter {
            let specializationAdvances = imperium.specializationAdvances
            
            // Create reverse mapping from specialization name to skill
            var specializationToSkillMap: [String: String] = [:]
            for (skillName, specializations) in SkillSpecializations.specializations {
                for specialization in specializations {
                    specializationToSkillMap[specialization] = skillName
                }
            }
            
            for (specializationName, advances) in specializationAdvances {
                // Show all specializations that exist in the character's data
                // Find skill name using improved lookup
                let skillName = findSkillForSpecialization(specializationName)
                    
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
                    
                    let characteristicAbbrev = skillCharacteristicMap[skillName] ?? "Int"
                    let characteristicValue = getCharacteristicValue(for: characteristicAbbrev, from: imperium)
                    let skillAdvanceCount = imperium.skillAdvances[skillName] ?? 0
                    let factionAdvanceCount = imperium.factionSkillAdvances[skillName] ?? 0
                    let totalSkillValue = characteristicValue + ((skillAdvanceCount + factionAdvanceCount) * 5)
                    let specializationTotalValue = totalSkillValue + (advances * 5)
                    
                    result.append(SpecializationRowData(
                        name: specializationName,
                        skillName: skillName,
                        advances: advances,
                        totalValue: specializationTotalValue
                    ))
            }
        }
        
        return result.sorted { $0.name < $1.name }
    }
    
    private func getCharacteristicValue(for abbreviation: String, from character: ImperiumCharacter) -> Int {
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
    
    private func deleteSpecialization(_ specializationName: String) {
        guard let imperium = imperiumCharacter else { return }
        var specializations = imperium.specializationAdvances
        specializations.removeValue(forKey: specializationName)
        imperium.specializationAdvances = specializations
        imperium.lastModified = Date()
        store.saveChanges()
    }
}

// MARK: - Add Specialization Sheet

struct AddSpecializationSheet: View {
    let character: ImperiumCharacter
    @ObservedObject var store: CharacterStore
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedSkill = ""
    @State private var selectedSpecialization = ""
    @State private var initialAdvances = 1
    
    var availableSkills: [String] {
        SkillSpecializations.specializations.keys.sorted()
    }
    
    var availableSpecializations: [String] {
        guard !selectedSkill.isEmpty,
              let skillSpecializations = SkillSpecializations.specializations[selectedSkill] else {
            return []
        }
        
        // Filter out specializations that already exist
        let currentSpecializations = character.specializationAdvances
        let filtered = skillSpecializations.filter { specialization in
            currentSpecializations[specialization] == nil
        }
        
        // If current selection is not available anymore, reset it
        if !selectedSpecialization.isEmpty && !filtered.contains(selectedSpecialization) {
            DispatchQueue.main.async {
                selectedSpecialization = ""
            }
        }
        
        return filtered
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Select Skill") {
                    Picker("Skill", selection: $selectedSkill) {
                        Text("Choose a skill...").tag("")
                        ForEach(availableSkills, id: \.self) { skill in
                            Text(skill).tag(skill)
                        }
                    }
                    .pickerStyle(.menu)
                    .onChange(of: selectedSkill) { _ in
                        selectedSpecialization = ""
                    }
                }
                
                if !selectedSkill.isEmpty {
                    Section("Select Specialization") {
                        Picker("Specialization", selection: $selectedSpecialization) {
                            Text("Choose...").tag("")
                            ForEach(availableSpecializations, id: \.self) { specialization in
                                Text(specialization).tag(specialization)
                            }
                        }
                        .pickerStyle(.menu)
                    }
                }
                
                if !selectedSpecialization.isEmpty {
                    Section("Initial Advances") {
                        HStack {
                            Text("Advances:")
                            Spacer()
                            
                            Button(action: {
                                initialAdvances = max(0, initialAdvances - 1)
                            }) {
                                Image(systemName: "minus")
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .foregroundColor(.primary)
                                    .frame(width: 30, height: 30)
                                    .background(Color(.systemGray5))
                                    .cornerRadius(6)
                            }
                            .buttonStyle(PlainButtonStyle())
                            .disabled(initialAdvances <= 0)
                            
                            Text("\(initialAdvances)")
                                .font(.body)
                                .fontWeight(.medium)
                                .frame(minWidth: 30)
                            
                            Button(action: {
                                initialAdvances = min(4, initialAdvances + 1)
                            }) {
                                Image(systemName: "plus")
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .foregroundColor(.primary)
                                    .frame(width: 30, height: 30)
                                    .background(Color(.systemGray5))
                                    .cornerRadius(6)
                            }
                            .buttonStyle(PlainButtonStyle())
                            .disabled(initialAdvances >= 4)
                        }
                    }
                }
                
                if !selectedSkill.isEmpty && availableSpecializations.isEmpty {
                    Section {
                        Text("All specializations for \(selectedSkill) are already added.")
                            .foregroundColor(.secondary)
                            .italic()
                    }
                }
            }
            .navigationTitle("Add Specialization")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                // Reset state when sheet appears to prevent picker validation errors
                selectedSkill = ""
                selectedSpecialization = ""
                initialAdvances = 1
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Add") {
                        addSpecialization()
                    }
                    .disabled(selectedSpecialization.isEmpty)
                }
            }
        }
    }
    
    private func addSpecialization() {
        guard !selectedSpecialization.isEmpty else { return }
        
        var specializations = character.specializationAdvances
        specializations[selectedSpecialization] = initialAdvances
        character.specializationAdvances = specializations
        character.lastModified = Date()
        store.saveChanges()
        dismiss()
    }
}