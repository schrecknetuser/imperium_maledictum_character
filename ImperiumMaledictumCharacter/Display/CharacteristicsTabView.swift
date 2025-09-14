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
    @State private var specializationToDelete: (name: String, skill: String) = ("", "")
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
    

    @State private var specializationsList: [SpecializationRowData] = []
    
    private func refreshSpecializationsList() {
        specializationsList = getSpecializationsList()
    }
    
    var body: some View {
        GeometryReader { geometry in
                ScrollView {
                    VStack(spacing: 20) {
                // Characteristics Table
                VStack(alignment: .leading, spacing: 12) {
                    Text("Characteristics")
                        .font(.headline)
                    
                    VStack(spacing: 0) {
                        // Header row with responsive sizing
                        HStack {
                            Text("Char.")
                                .font(.caption)
                                .fontWeight(.medium)
                                .frame(width: max(40, geometry.size.width * 0.08), alignment: .leading)
                            Text("Base")
                                .font(.caption)
                                .fontWeight(.medium)
                                .frame(width: isEditMode ? max(80, geometry.size.width * 0.15) : max(50, geometry.size.width * 0.1), alignment: .center)
                            Text("Adv.")
                                .font(.caption)
                                .fontWeight(.medium)
                                .frame(width: isEditMode ? max(80, geometry.size.width * 0.15) : max(50, geometry.size.width * 0.1), alignment: .center)
                            Text("Total")
                                .font(.caption)
                                .fontWeight(.medium)
                                .frame(width: max(50, geometry.size.width * 0.1), alignment: .center)
                            Spacer()
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 8)
                        .background(Color(.systemGray5))
                        
                        ForEach(Array(getCharacteristicsList().enumerated()), id: \.element.abbreviation) { index, characteristic in
                            VStack(spacing: 0) {
                                HStack {
                                    Text(characteristic.abbreviation)
                                        .font(.caption)
                                        .frame(width: max(40, geometry.size.width * 0.08), alignment: .leading)
                                    
                                    // Base Value Section with responsive sizing
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
                                        .frame(width: max(80, geometry.size.width * 0.15), alignment: .center)
                                    } else {
                                        Text("\(characteristic.baseValue)")
                                            .font(.caption)
                                            .frame(width: max(50, geometry.size.width * 0.1), alignment: .center)
                                    }
                                    
                                    // Advances Section with responsive sizing
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
                                        .frame(width: max(80, geometry.size.width * 0.15), alignment: .center)
                                    } else {
                                        Text("\(characteristic.advances)")
                                            .font(.caption)
                                            .frame(width: max(50, geometry.size.width * 0.1), alignment: .center)
                                    }
                                    
                                    Text("\(characteristic.totalValue)")
                                        .font(.caption)
                                        .fontWeight(.medium)
                                        .frame(width: max(50, geometry.size.width * 0.1), alignment: .center)
                                    Spacer()
                                }
                                .padding(.horizontal)
                                .padding(.vertical, 6)
                                
                                if index < getCharacteristicsList().count - 1 {
                                    Divider()
                                        .padding(.horizontal)
                                }
                            }
                        }
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                
                // Skills Table
                VStack(alignment: .leading, spacing: 12) {
                    Text("Skills")
                        .font(.headline)
                    
                    VStack(spacing: 0) {
                        // Header row with responsive sizing
                        HStack {
                            Text("Skill")
                                .font(.caption)
                                .fontWeight(.medium)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            Text("Char.")
                                .font(.caption)
                                .fontWeight(.medium)
                                .frame(width: max(40, geometry.size.width * 0.08), alignment: .center)
                            Text("Adv.")
                                .font(.caption)
                                .fontWeight(.medium)
                                .frame(width: max(55, geometry.size.width * 0.12), alignment: .center)
                            Text("Total")
                                .font(.caption)
                                .fontWeight(.medium)
                                .frame(width: max(45, geometry.size.width * 0.1), alignment: .center)
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 8)
                        .background(Color(.systemGray5))
                        
                        ForEach(Array(getSkillsList().enumerated()), id: \.element.name) { index, skill in
                            VStack(spacing: 0) {
                                HStack {
                                    Text(skill.name)
                                        .font(.caption)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                    Text(skill.characteristicAbbreviation)
                                        .font(.caption)
                                        .frame(width: max(40, geometry.size.width * 0.08), alignment: .center)
                                    
                                    if isEditMode {
                                        // Editable dropdown for advances with better sizing
                                        Picker("Advances", selection: getSkillAdvanceBinding(for: skill.name)) {
                                            ForEach(0...4, id: \.self) { value in
                                                Text("\(value)").tag(value)
                                            }
                                        }
                                        .pickerStyle(MenuPickerStyle())
                                        .frame(width: max(55, geometry.size.width * 0.12))
                                    } else {
                                        Text("\(skill.advances)")
                                            .font(.caption)
                                            .frame(width: max(55, geometry.size.width * 0.12), alignment: .center)
                                    }
                                    
                                    Text("\(skill.totalValue)")
                                        .font(.caption)
                                        .fontWeight(.medium)
                                        .frame(width: max(45, geometry.size.width * 0.1), alignment: .center)
                                }
                                .padding(.horizontal)
                                .padding(.vertical, 6)
                                
                                if index < getSkillsList().count - 1 {
                                    Divider()
                                        .padding(.horizontal)
                                }
                            }
                        }
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                
                // Specializations Table
                VStack(alignment: .leading, spacing: 12) {
                    Text("Specializations")
                        .font(.headline)
                    
                    VStack(spacing: 0) {
                        // Header row with dynamic sizing
                        HStack {
                            Text("Specialization")
                                .font(.system(.caption, design: .default))
                                .fontWeight(.medium)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .frame(minWidth: 120)
                            Text("Skill")
                                .font(.system(.caption, design: .default))
                                .fontWeight(.medium)
                                .frame(width: max(80, geometry.size.width * 0.15), alignment: .center)
                            Text("Adv.")
                                .font(.system(.caption, design: .default))
                                .fontWeight(.medium)
                                .frame(width: max(60, geometry.size.width * 0.12), alignment: .center)
                            Text("Total")
                                .font(.system(.caption, design: .default))
                                .fontWeight(.medium)
                                .frame(width: max(50, geometry.size.width * 0.1), alignment: .center)
                            
                            // Space for delete button in edit mode
                            if isEditMode {
                                Text("") // Empty header for delete column
                                    .frame(width: 40, alignment: .center)
                            }
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 8)
                        .background(Color(.systemGray5))
                        
                        ForEach(Array(specializationsList.enumerated()), id: \.element.id) { index, specialization in
                            VStack(spacing: 0) {
                                HStack {
                                    Text(specialization.name)
                                        .font(.system(.caption, design: .default))
                                        .lineLimit(2)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .frame(minWidth: 120)
                                    Text(specialization.skillName)
                                        .font(.system(.caption, design: .default))
                                        .lineLimit(1)
                                        .frame(width: max(80, geometry.size.width * 0.15), alignment: .center)
                                    
                                    // Advances column - consistent width in both modes with better responsive sizing
                                    if isEditMode {
                                        // Editable dropdown for advances with improved sizing
                                        Picker("Advances", selection: getSpecializationAdvanceBinding(for: specialization.name, skill: specialization.skillName)) {
                                            ForEach(0...4, id: \.self) { value in
                                                Text("\(value)").tag(value)
                                            }
                                        }
                                        .pickerStyle(MenuPickerStyle())
                                        .frame(width: max(60, geometry.size.width * 0.12), alignment: .center)
                                    } else {
                                        Text("\(specialization.advances)")
                                            .font(.system(.caption, design: .default))
                                            .frame(width: max(60, geometry.size.width * 0.12), alignment: .center)
                                    }
                                    
                                    // Total column
                                    Text("\(specialization.totalValue)")
                                        .font(.system(.caption, design: .default))
                                        .fontWeight(.medium)
                                        .frame(width: max(50, geometry.size.width * 0.1), alignment: .center)
                                    
                                    // Delete button column - only in edit mode, fixed width
                                    if isEditMode {
                                        Button(action: {
                                            specializationToDelete = (name: specialization.name, skill: specialization.skillName)
                                            showingDeleteConfirmation = true
                                        }) {
                                            Image(systemName: "trash")
                                                .font(.system(.caption, design: .default))
                                                .foregroundColor(.red)
                                        }
                                        .frame(width: 40, height: 25)
                                        .background(Color(.systemGray5))
                                        .cornerRadius(6)
                                    }
                                }
                                .padding(.horizontal)
                                .padding(.vertical, 6)
                                
                                if index < specializationsList.count - 1 {
                                    Divider()
                                        .padding(.horizontal)
                                }
                            }
                        }
                        
                        // Add new specialization button in edit mode
                        if isEditMode {
                            Button(action: {
                                showingAddSpecializationSheet = true
                            }) {
                                HStack {
                                    Image(systemName: "plus")
                                        .font(.system(.caption, design: .default))
                                    Text("Add Specialization")
                                        .font(.system(.caption, design: .default))
                                    Spacer()
                                }
                                .padding(.horizontal)
                                .padding(.vertical, 6)
                                .background(Color(.systemBlue).opacity(0.1))
                                .foregroundColor(.blue)
                            }
                        }
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
            }
            .padding()
            .padding(.bottom, 80) // Extra space for floating buttons
            }
        }
        .navigationTitle("Stats")
        .navigationBarTitleDisplayMode(.inline)
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
        .sheet(isPresented: $showingAddSpecializationSheet, onDismiss: {
            // Refresh the specializations list when sheet is dismissed (in case something was added)
            refreshSpecializationsList()
        }) {
            if let imperium = imperiumCharacter {
                AddSpecializationSheet(character: imperium, store: store)
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
        .alert("Delete Specialization", isPresented: $showingDeleteConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                deleteSpecialization(specializationToDelete.name, skill: specializationToDelete.skill)
            }
        } message: {
            Text("Are you sure you want to delete the specialization '\(specializationToDelete.name) (\(specializationToDelete.skill))'? This action cannot be undone.")
        }
        .onAppear {
            // Migrate legacy data if needed when view appears
            imperiumCharacter?.migrateFromLegacySpecializations()
            // Refresh the specializations list
            refreshSpecializationsList()
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
                let originalSnapshot = store.createSnapshot(of: imperium)
                
                var characteristics = imperium.characteristics
                if var characteristic = characteristics[characteristicName] {
                    characteristic.initialValue = max(1, newValue) // Minimum value of 1
                    characteristics[characteristicName] = characteristic
                    imperium.characteristics = characteristics
                    store.saveCharacterWithAutoChangeTracking(imperium, originalSnapshot: originalSnapshot)
                    // Refresh specializations list since characteristic values affect specialization totals
                    refreshSpecializationsList()
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
                let originalSnapshot = store.createSnapshot(of: imperium)
                
                var characteristics = imperium.characteristics
                if var characteristic = characteristics[characteristicName] {
                    characteristic.advances = newValue
                    characteristics[characteristicName] = characteristic
                    imperium.characteristics = characteristics
                    store.saveCharacterWithAutoChangeTracking(imperium, originalSnapshot: originalSnapshot)
                    // Refresh specializations list since characteristic values affect specialization totals
                    refreshSpecializationsList()
                }
            }
        )
    }
    
    private func getSkillAdvanceBinding(for skillName: String) -> Binding<Int> {
        return Binding<Int>(
            get: {
                guard let imperium = imperiumCharacter else { return 0 }
                let userAdvances = imperium.skillAdvances[skillName] ?? 0
                let factionAdvances = imperium.factionSkillAdvances[skillName] ?? 0
                return userAdvances + factionAdvances
            },
            set: { newValue in
                guard let imperium = imperiumCharacter else { return }
                let originalSnapshot = store.createSnapshot(of: imperium)
                
                // Calculate what the user advances should be to achieve the desired total
                let factionAdvances = imperium.factionSkillAdvances[skillName] ?? 0
                let targetUserAdvances = max(0, newValue - factionAdvances)
                
                var skillAdvances = imperium.skillAdvances
                skillAdvances[skillName] = targetUserAdvances
                imperium.skillAdvances = skillAdvances
                store.saveCharacterWithAutoChangeTracking(imperium, originalSnapshot: originalSnapshot)
                // Refresh specializations list since skill advances affect specialization totals
                refreshSpecializationsList()
            }
        )
    }
    
    private func getSpecializationAdvanceBinding(for specializationName: String, skill skillName: String) -> Binding<Int> {
        return Binding<Int>(
            get: {
                guard let imperium = imperiumCharacter else { return 0 }
                return imperium.getSpecializationAdvances(specialization: specializationName, skill: skillName)
            },
            set: { newValue in
                guard let imperium = imperiumCharacter else { return }
                let originalSnapshot = store.createSnapshot(of: imperium)
                imperium.setSpecializationAdvances(specialization: specializationName, skill: skillName, advances: newValue)
                store.saveCharacterWithAutoChangeTracking(imperium, originalSnapshot: originalSnapshot)
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
    


    private func getSpecializationsList() -> [SpecializationRowData] {
        var result: [SpecializationRowData] = []
        
        if let imperium = imperiumCharacter {
            // Get all visible specializations using new system
            let visibleSpecs = imperium.getVisibleSpecializations()
            
            for spec in visibleSpecs {
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
                
                let characteristicAbbrev = skillCharacteristicMap[spec.skill] ?? "Int"
                let characteristicValue = getCharacteristicValue(for: characteristicAbbrev, from: imperium)
                let skillAdvanceCount = imperium.skillAdvances[spec.skill] ?? 0
                let factionAdvanceCount = imperium.factionSkillAdvances[spec.skill] ?? 0
                let totalSkillValue = characteristicValue + ((skillAdvanceCount + factionAdvanceCount) * 5)
                let specializationTotalValue = totalSkillValue + (spec.advances * 5)
                
                result.append(SpecializationRowData(
                    name: spec.name,
                    skillName: spec.skill,
                    advances: spec.advances,
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
    
    private func deleteSpecialization(_ specializationName: String, skill: String) {
        guard let imperium = imperiumCharacter else { return }
        let originalSnapshot = store.createSnapshot(of: imperium)
        
        // Use the new delete method that sets value to 0
        imperium.deleteSpecialization(specialization: specializationName, skill: skill)
        
        store.saveCharacterWithAutoChangeTracking(imperium, originalSnapshot: originalSnapshot)
        
        // Refresh the specializations list after deletion
        refreshSpecializationsList()
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
        
        // Filter out specializations that already exist for this skill
        return skillSpecializations.filter { specialization in
            character.getSpecializationAdvances(specialization: specialization, skill: selectedSkill) == 0
        }
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
                        // Reset picker state before dismissing to prevent validation errors
                        selectedSkill = ""
                        selectedSpecialization = ""
                        initialAdvances = 1
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
        guard !selectedSpecialization.isEmpty, !selectedSkill.isEmpty else { return }
        
        let originalSnapshot = store.createSnapshot(of: character)
        
        // Use the new system to set specialization advances 
        character.setSpecializationAdvances(specialization: selectedSpecialization, skill: selectedSkill, advances: initialAdvances)
        
        store.saveCharacterWithAutoChangeTracking(character, originalSnapshot: originalSnapshot)
        
        // Reset picker state before dismissing to prevent validation errors
        selectedSkill = ""
        selectedSpecialization = ""
        initialAdvances = 1
        
        dismiss()
    }
}