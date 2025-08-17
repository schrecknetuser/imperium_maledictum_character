//
//  CharacterDetailView.swift
//  ImperiumMaledictumCharacter
//
//  Created by User on 11.01.2025.
//

import SwiftUI

struct CharacterDetailView: View {
    @Binding var character: any BaseCharacter
    @ObservedObject var store: CharacterStore
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedTab: Int = 0
    @State private var isEditMode = false
    
    var imperiumCharacter: ImperiumCharacter? {
        return character as? ImperiumCharacter
    }
    
    var body: some View {
        TabView(selection: $selectedTab) {
            OverviewTab(character: $character, store: store, isEditMode: $isEditMode)
                .tabItem {
                    Image(systemName: "person.circle")
                    Text("Overview")
                }
                .tag(0)
            
            CharacteristicsTab(character: character, store: store, isEditMode: $isEditMode)
                .tabItem {
                    Image(systemName: "chart.bar")
                    Text("Stats")
                }
                .tag(1)
            
            TalentsTab(character: character, store: store, isEditMode: $isEditMode)
                .tabItem {
                    Image(systemName: "star.circle")
                    Text("Talents")
                }
                .tag(2)
            
            EquipmentTab(character: character, store: store, isEditMode: $isEditMode)
                .tabItem {
                    Image(systemName: "bag")
                    Text("Equipment")
                }
                .tag(3)
            
            if imperiumCharacter?.role.lowercased().contains("psyker") == true {
                PsychicPowersTab(character: character, store: store, isEditMode: $isEditMode)
                    .tabItem {
                        Image(systemName: "brain")
                        Text("Psychic")
                    }
                    .tag(4)
            }
        }
        .navigationTitle(character.name.isEmpty ? "Unnamed Character" : character.name)
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                if isEditMode {
                    Button("Done") {
                        // Save all changes
                        if let imperium = character as? ImperiumCharacter {
                            imperium.lastModified = Date()
                        }
                        store.saveChanges()
                        isEditMode = false
                    }
                } else {
                    Button("Edit") {
                        isEditMode = true
                    }
                }
            }
        }
    }
}

// MARK: - Overview Tab

struct OverviewTab: View {
    @Binding var character: any BaseCharacter
    @ObservedObject var store: CharacterStore
    @Binding var isEditMode: Bool
    @State private var showingStatusPopup = false
    @State private var showingInjuriesPopup = false
    @State private var showingConditionsPopup = false
    
    var imperiumCharacter: ImperiumCharacter? {
        return character as? ImperiumCharacter
    }
    
    var imperiumCharacterBinding: Binding<ImperiumCharacter>? {
        guard character is ImperiumCharacter else { return nil }
        return Binding(
            get: { character as! ImperiumCharacter },
            set: { newValue in
                character = newValue
            }
        )
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Character Header
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(character.characterType.symbol)
                            .font(.largeTitle)
                        
                        VStack(alignment: .leading) {
                            if isEditMode {
                                TextField("Character Name", text: $character.name)
                                    .font(.title)
                                    .fontWeight(.bold)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                            } else {
                                Text(character.name.isEmpty ? "Unnamed Character" : character.name)
                                    .font(.title)
                                    .fontWeight(.bold)
                            }
                            
                            if isEditMode {
                                TextField("Faction", text: $character.faction)
                                    .font(.headline)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                            } else if !character.faction.isEmpty {
                                Text(character.faction)
                                    .font(.headline)
                                    .foregroundColor(.secondary)
                            }
                            
                            if isEditMode {
                                TextField("Role", text: $character.role)
                                    .font(.subheadline)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                            } else if !character.role.isEmpty {
                                Text(character.role)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            
                            if let imperium = imperiumCharacter {
                                if isEditMode {
                                    let homeworldBinding = Binding<String>(
                                        get: { imperium.homeworld },
                                        set: { imperium.homeworld = $0 }
                                    )
                                    TextField("Homeworld", text: homeworldBinding)
                                        .font(.subheadline)
                                        .textFieldStyle(RoundedBorderTextFieldStyle())
                                } else if !imperium.homeworld.isEmpty {
                                    Text(imperium.homeworld)
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                        
                        Spacer()
                    }
                    
                    if isEditMode {
                        TextField("Campaign", text: $character.campaign)
                            .font(.caption)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    } else if !character.campaign.isEmpty {
                        Text("Campaign: \(character.campaign)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                
                // Character Goals and Description
                if let imperium = imperiumCharacter {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Character Information")
                            .font(.headline)
                        
                        if isEditMode {
                            let shortTermGoalBinding = Binding<String>(
                                get: { imperium.shortTermGoal },
                                set: { imperium.shortTermGoal = $0 }
                            )
                            VStack(alignment: .leading) {
                                Text("Short-term Goal")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                TextField("Short-term Goal", text: shortTermGoalBinding, axis: .vertical)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .lineLimit(2...4)
                            }
                            
                            let longTermGoalBinding = Binding<String>(
                                get: { imperium.longTermGoal },
                                set: { imperium.longTermGoal = $0 }
                            )
                            VStack(alignment: .leading) {
                                Text("Long-term Goal")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                TextField("Long-term Goal", text: longTermGoalBinding, axis: .vertical)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .lineLimit(2...4)
                            }
                            
                            let descriptionBinding = Binding<String>(
                                get: { imperium.characterDescription },
                                set: { imperium.characterDescription = $0 }
                            )
                            VStack(alignment: .leading) {
                                Text("Description")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                TextField("Character Description", text: descriptionBinding, axis: .vertical)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .lineLimit(3...6)
                            }
                        } else {
                            if !imperium.shortTermGoal.isEmpty {
                                DetailRow(title: "Short-term Goal", value: imperium.shortTermGoal)
                            }
                            
                            if !imperium.longTermGoal.isEmpty {
                                DetailRow(title: "Long-term Goal", value: imperium.longTermGoal)
                            }
                            
                            if !imperium.characterDescription.isEmpty {
                                DetailRow(title: "Description", value: imperium.characterDescription)
                            }
                            
                            if imperium.shortTermGoal.isEmpty && imperium.longTermGoal.isEmpty && imperium.characterDescription.isEmpty {
                                Text("No character information provided")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .italic()
                            }
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                }
                
                // Character Details
                if let imperium = imperiumCharacter {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Background Details")
                            .font(.headline)
                        
                        if !imperium.background.isEmpty {
                            DetailRow(title: "Background", value: imperium.background)
                        }
                        
                        if !imperium.goal.isEmpty {
                            DetailRow(title: "Goal", value: imperium.goal)
                        }
                        
                        if !imperium.nemesis.isEmpty {
                            DetailRow(title: "Nemesis", value: imperium.nemesis)
                        }
                        
                        if imperium.solars > 0 {
                            DetailRow(title: "Wealth", value: "\(imperium.solars) Solars")
                        }
                        
                        if imperium.background.isEmpty && imperium.goal.isEmpty && imperium.nemesis.isEmpty && imperium.solars == 0 {
                            Text("No background details provided")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .italic()
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                }
                
                // Experience Block
                if let imperium = imperiumCharacter {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Experience")
                            .font(.headline)
                        
                        if isEditMode {
                            VStack(spacing: 8) {
                                let totalExperienceBinding = Binding<Int>(
                                    get: { imperium.totalExperience },
                                    set: { imperium.totalExperience = $0 }
                                )
                                HStack {
                                    Text("Total XP")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    Spacer()
                                    TextField("Total", value: totalExperienceBinding, format: .number)
                                        .textFieldStyle(RoundedBorderTextFieldStyle())
                                        .frame(width: 80)
                                        .keyboardType(.numberPad)
                                }
                                
                                let spentExperienceBinding = Binding<Int>(
                                    get: { imperium.spentExperience },
                                    set: { imperium.spentExperience = $0 }
                                )
                                HStack {
                                    Text("Spent XP")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    Spacer()
                                    TextField("Spent", value: spentExperienceBinding, format: .number)
                                        .textFieldStyle(RoundedBorderTextFieldStyle())
                                        .frame(width: 80)
                                        .keyboardType(.numberPad)
                                }
                                
                                HStack {
                                    Text("Available XP")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    Spacer()
                                    Text("\(imperium.availableExperience)")
                                        .font(.title3)
                                        .fontWeight(.bold)
                                        .foregroundColor(.green)
                                }
                            }
                        } else {
                            HStack(spacing: 20) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Total XP")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    Text("\(imperium.totalExperience)")
                                        .font(.title2)
                                        .fontWeight(.bold)
                                }
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Spent XP")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    Text("\(imperium.spentExperience)")
                                        .font(.title2)
                                        .fontWeight(.bold)
                                }
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Available XP")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    Text("\(imperium.availableExperience)")
                                        .font(.title2)
                                        .fontWeight(.bold)
                                        .foregroundColor(.green)
                                }
                                
                                Spacer()
                            }
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                }
            }
            .padding()
        }
        .overlay(alignment: .bottomTrailing) {
            VStack(spacing: 12) {
                // Conditions Button
                Button {
                    showingConditionsPopup = true
                } label: {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.title2)
                        .foregroundColor(.white)
                        .frame(width: 56, height: 56)
                        .background(Color.orange)
                        .clipShape(Circle())
                        .shadow(radius: 4)
                }
                
                // Injuries Button
                Button {
                    showingInjuriesPopup = true
                } label: {
                    Image(systemName: "bandage")
                        .font(.title2)
                        .foregroundColor(.white)
                        .frame(width: 56, height: 56)
                        .background(Color.red)
                        .clipShape(Circle())
                        .shadow(radius: 4)
                }
                
                // Status Button
                Button {
                    showingStatusPopup = true
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
        .sheet(isPresented: $showingStatusPopup) {
            if let binding = imperiumCharacterBinding {
                StatusPopupView(character: binding, store: store)
            }
        }
        .sheet(isPresented: $showingInjuriesPopup) {
            if let binding = imperiumCharacterBinding {
                InjuriesPopupView(character: binding, store: store)
            }
        }
        .sheet(isPresented: $showingConditionsPopup) {
            if let binding = imperiumCharacterBinding {
                ConditionsPopupView(character: binding, store: store)
            }
        }
    }
}

struct StatusBox: View {
    let title: String
    let current: Int
    let maximum: Int
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text("\(current)/\(maximum)")
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(color)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(color.opacity(0.1))
        .cornerRadius(8)
    }
}

struct DetailRow: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            Text(value)
                .font(.body)
        }
    }
}

// MARK: - Characteristics Tab

struct CharacteristicsTab: View {
    let character: any BaseCharacter
    @ObservedObject var store: CharacterStore
    @Binding var isEditMode: Bool
    @State private var showingAddSpecializationSheet = false
    
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
                                
                                if isEditMode {
                                    // Editable dropdown for advances
                                    Picker("Advances", selection: getCharacteristicAdvanceBinding(for: characteristic.name)) {
                                        ForEach(0...4, id: \.self) { value in
                                            Text("\(value)").tag(value)
                                        }
                                    }
                                    .pickerStyle(MenuPickerStyle())
                                    .frame(width: 40)
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
                if advances > 0 || isEditMode {
                    // Find skill name by lookup in specializations map
                    let skillName = specializationToSkillMap[specializationName] ?? "Unknown"
                    
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
}

// MARK: - Data structures moved to CharacterBase.swift to avoid duplication

struct CharacteristicDisplay: View {
    let name: String
    let value: Int
    
    var body: some View {
        VStack(spacing: 8) {
            Text(name)
                .font(.headline)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
            
            Text("\(value)")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.primary)
        }
        .frame(maxWidth: .infinity, minHeight: 100)
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

// MARK: - Skills Tab

// MARK: - Add Specialization Sheet

struct AddSpecializationSheet: View {
    let character: ImperiumCharacter
    @ObservedObject var store: CharacterStore
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedSkill = ""
    @State private var selectedSpecialization = ""
    
    var availableSkills: [String] {
        SkillSpecializations.specializations.keys.sorted()
    }
    
    var availableSpecializations: [String] {
        guard !selectedSkill.isEmpty,
              let skillSpecializations = SkillSpecializations.specializations[selectedSkill] else {
            return []
        }
        
        // Filter out specializations that already have advances > 0
        let currentSpecializations = character.specializationAdvances
        return skillSpecializations.filter { specialization in
            (currentSpecializations[specialization] ?? 0) == 0
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
                            Text("Choose a specialization...").tag("")
                            ForEach(availableSpecializations, id: \.self) { specialization in
                                Text(specialization).tag(specialization)
                            }
                        }
                        .pickerStyle(.menu)
                    }
                }
                
                if !availableSpecializations.isEmpty && availableSpecializations.count == 0 {
                    Section {
                        Text("All specializations for \(selectedSkill) are already added.")
                            .foregroundColor(.secondary)
                            .italic()
                    }
                }
            }
            .navigationTitle("Add Specialization")
            .navigationBarTitleDisplayMode(.inline)
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
        specializations[selectedSpecialization] = 0
        character.specializationAdvances = specializations
        character.lastModified = Date()
        store.saveChanges()
        dismiss()
    }
}

// MARK: - Talents Tab

struct TalentsTab: View {
    let character: any BaseCharacter
    @ObservedObject var store: CharacterStore
    @Binding var isEditMode: Bool
    @State private var showingAddTalentSheet = false
    
    var imperiumCharacter: ImperiumCharacter? {
        return character as? ImperiumCharacter
    }
    
    var body: some View {
        NavigationView {
            List {
                if let imperium = imperiumCharacter {
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
                                    removeTalent(talent)
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
                } else {
                    Text("Talents not available for this character type")
                        .foregroundColor(.secondary)
                }
            }
            .navigationTitle("Talents")
            .navigationBarTitleDisplayMode(.inline)
        }
        .sheet(isPresented: $showingAddTalentSheet) {
            if let imperium = imperiumCharacter {
                AddTalentSheet(character: imperium, store: store)
            }
        }
    }
    
    private func removeTalent(_ talent: String) {
        guard let imperium = imperiumCharacter else { return }
        var talents = imperium.talentNames
        talents.removeAll { $0 == talent }
        imperium.talentNames = talents
        imperium.lastModified = Date()
        store.saveChanges()
    }
}

struct AddTalentSheet: View {
    let character: ImperiumCharacter
    @ObservedObject var store: CharacterStore
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
        character.lastModified = Date()
        store.saveChanges()
        dismiss()
    }
}

// MARK: - Equipment Tab

struct EquipmentTab: View {
    let character: any BaseCharacter
    @ObservedObject var store: CharacterStore
    @Binding var isEditMode: Bool
    @State private var showingAddEquipmentSheet = false
    @State private var showingAddWeaponSheet = false
    @State private var showingEditEquipmentSheet = false
    @State private var showingEditWeaponSheet = false
    @State private var editingEquipment: Equipment?
    @State private var editingWeapon: Weapon?
    
    var imperiumCharacter: ImperiumCharacter? {
        return character as? ImperiumCharacter
    }
    
    var body: some View {
        NavigationView {
            List {
                if let imperium = imperiumCharacter {
                    Section("Equipment") {
                        ForEach(imperium.equipmentList, id: \.name) { equipment in
                            HStack {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(equipment.name)
                                        .font(.body)
                                    
                                    if !equipment.equipmentDescription.isEmpty {
                                        Text(equipment.equipmentDescription)
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    // Show traits, qualities, and flaws
                                    let details = buildEquipmentDetails(equipment)
                                    if !details.isEmpty {
                                        Text(details)
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                            .italic()
                                    }
                                    
                                    // Show stats
                                    Text("Encumbrance: \(equipment.encumbrance), Cost: \(equipment.cost), \(equipment.availability)")
                                        .font(.caption2)
                                        .foregroundColor(.secondary)
                                }
                                
                                Spacer()
                                
                                if isEditMode {
                                    HStack(spacing: 8) {
                                        Button(action: {
                                            editEquipment(equipment)
                                        }) {
                                            Image(systemName: "pencil.circle.fill")
                                                .foregroundColor(.blue)
                                        }
                                        .buttonStyle(PlainButtonStyle())
                                        
                                        Button(action: {
                                            removeEquipment(equipment)
                                        }) {
                                            Image(systemName: "minus.circle.fill")
                                                .foregroundColor(.red)
                                        }
                                        .buttonStyle(PlainButtonStyle())
                                    }
                                }
                            }
                        }
                        
                        if isEditMode {
                            Button(action: {
                                showingAddEquipmentSheet = true
                            }) {
                                HStack {
                                    Image(systemName: "plus.circle.fill")
                                        .foregroundColor(.blue)
                                    Text("Add Equipment")
                                        .foregroundColor(.blue)
                                    Spacer()
                                }
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                        
                        if imperium.equipmentList.isEmpty && !isEditMode {
                            Text("No equipment")
                                .foregroundColor(.secondary)
                                .italic()
                        }
                    }
                    
                    Section("Weapons") {
                        ForEach(imperium.weaponList, id: \.name) { weapon in
                            HStack {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(weapon.name)
                                        .font(.body)
                                    
                                    // Show weapon stats
                                    Text("Damage: \(weapon.damage), Range: \(weapon.range), Magazine: \(weapon.magazine)")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    
                                    // Show specialization
                                    Text("Specialization: \(weapon.specialization)")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    
                                    // Show traits, qualities, flaws, and modifications
                                    let details = buildWeaponDetails(weapon)
                                    if !details.isEmpty {
                                        Text(details)
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                            .italic()
                                    }
                                    
                                    // Show other stats
                                    Text("Encumbrance: \(weapon.encumbrance), Cost: \(weapon.cost), \(weapon.availability)")
                                        .font(.caption2)
                                        .foregroundColor(.secondary)
                                }
                                
                                Spacer()
                                
                                if isEditMode {
                                    HStack(spacing: 8) {
                                        Button(action: {
                                            editWeapon(weapon)
                                        }) {
                                            Image(systemName: "pencil.circle.fill")
                                                .foregroundColor(.blue)
                                        }
                                        .buttonStyle(PlainButtonStyle())
                                        
                                        Button(action: {
                                            removeWeapon(weapon)
                                        }) {
                                            Image(systemName: "minus.circle.fill")
                                                .foregroundColor(.red)
                                        }
                                        .buttonStyle(PlainButtonStyle())
                                    }
                                }
                            }
                        }
                        
                        if isEditMode {
                            Button(action: {
                                showingAddWeaponSheet = true
                            }) {
                                HStack {
                                    Image(systemName: "plus.circle.fill")
                                        .foregroundColor(.blue)
                                    Text("Add Weapon")
                                        .foregroundColor(.blue)
                                    Spacer()
                                }
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                        
                        if imperium.weaponList.isEmpty && !isEditMode {
                            Text("No weapons")
                                .foregroundColor(.secondary)
                                .italic()
                        }
                    }
                } else {
                    Text("Equipment not available for this character type")
                        .foregroundColor(.secondary)
                }
            }
            .navigationTitle("Equipment")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                // Migrate old string-based data to new object-based system
                imperiumCharacter?.migrateEquipmentAndWeapons()
            }
        }
        .sheet(isPresented: $showingAddEquipmentSheet) {
            if let imperium = imperiumCharacter {
                ComprehensiveEquipmentSheet(character: imperium, store: store, isWeapon: false)
            }
        }
        .sheet(isPresented: $showingAddWeaponSheet) {
            if let imperium = imperiumCharacter {
                ComprehensiveEquipmentSheet(character: imperium, store: store, isWeapon: true)
            }
        }
        .sheet(isPresented: $showingEditEquipmentSheet) {
            if let imperium = imperiumCharacter, let equipment = editingEquipment {
                ComprehensiveEquipmentSheet(character: imperium, store: store, isWeapon: false, editingEquipment: equipment)
                    .onDisappear {
                        // Clear editing state when sheet is dismissed
                        editingEquipment = nil
                    }
            }
        }
        .sheet(isPresented: $showingEditWeaponSheet) {
            if let imperium = imperiumCharacter, let weapon = editingWeapon {
                ComprehensiveEquipmentSheet(character: imperium, store: store, isWeapon: true, editingWeapon: weapon)
                    .onDisappear {
                        // Clear editing state when sheet is dismissed
                        editingWeapon = nil
                    }
            }
        }
    }
    
    private func buildEquipmentDetails(_ equipment: Equipment) -> String {
        var details: [String] = []
        
        if !equipment.traits.isEmpty {
            details.append("Traits: " + equipment.traits.map { $0.displayName }.joined(separator: ", "))
        }
        
        if !equipment.qualities.isEmpty {
            details.append("Qualities: " + equipment.qualities.joined(separator: ", "))
        }
        
        if !equipment.flaws.isEmpty {
            details.append("Flaws: " + equipment.flaws.joined(separator: ", "))
        }
        
        return details.joined(separator: "\n")
    }
    
    private func buildWeaponDetails(_ weapon: Weapon) -> String {
        var details: [String] = []
        
        if !weapon.weaponTraits.isEmpty {
            details.append("Traits: " + weapon.weaponTraits.map { $0.displayName }.joined(separator: ", "))
        }
        
        if !weapon.modifications.isEmpty {
            details.append("Modifications: " + weapon.modifications.joined(separator: ", "))
        }
        
        if !weapon.qualities.isEmpty {
            details.append("Qualities: " + weapon.qualities.joined(separator: ", "))
        }
        
        if !weapon.flaws.isEmpty {
            details.append("Flaws: " + weapon.flaws.joined(separator: ", "))
        }
        
        return details.joined(separator: "\n")
    }
    
    private func editEquipment(_ equipment: Equipment) {
        // Close any open sheets first
        showingEditWeaponSheet = false
        showingEditEquipmentSheet = false
        
        // Set the editing equipment directly and present the sheet
        editingEquipment = equipment
        editingWeapon = nil
        showingEditEquipmentSheet = true
    }
    
    private func editWeapon(_ weapon: Weapon) {
        // Close any open sheets first
        showingEditEquipmentSheet = false
        showingEditWeaponSheet = false
        
        // Set the editing weapon directly and present the sheet
        editingWeapon = weapon
        editingEquipment = nil
        showingEditWeaponSheet = true
    }
    
    private func removeEquipment(_ equipment: Equipment) {
        guard let imperium = imperiumCharacter else { return }
        var equipmentList = imperium.equipmentList
        equipmentList.removeAll { $0.name == equipment.name }
        imperium.equipmentList = equipmentList
        imperium.lastModified = Date()
        store.saveChanges()
    }
    
    private func removeWeapon(_ weapon: Weapon) {
        guard let imperium = imperiumCharacter else { return }
        var weaponList = imperium.weaponList
        weaponList.removeAll { $0.name == weapon.name }
        imperium.weaponList = weaponList
        imperium.lastModified = Date()
        store.saveChanges()
    }
}

struct ComprehensiveEquipmentSheet: View {
    let character: ImperiumCharacter
    @ObservedObject var store: CharacterStore
    let isWeapon: Bool
    let editingEquipment: Equipment?
    let editingWeapon: Weapon?
    @Environment(\.dismiss) private var dismiss
    
    // Equipment properties
    @State private var itemName = ""
    @State private var itemDescription = ""
    @State private var encumbrance = 0
    @State private var cost = 0
    @State private var availability = AvailabilityLevels.common
    @State private var selectedQualities: Set<String> = []
    @State private var selectedFlaws: Set<String> = []
    @State private var selectedTraits: Set<String> = []
    
    // Weapon-specific properties
    @State private var specialization = WeaponSpecializations.none
    @State private var damage = ""
    @State private var range = WeaponRanges.short
    @State private var magazine = 0
    @State private var selectedWeaponTraits: Set<String> = []
    @State private var selectedModifications: Set<String> = []
    
    // UI state
    @State private var showingTraitPicker = false
    @State private var showingWeaponTraitPicker = false
    
    init(character: ImperiumCharacter, store: CharacterStore, isWeapon: Bool, editingEquipment: Equipment? = nil, editingWeapon: Weapon? = nil) {
        self.character = character
        self.store = store
        self.isWeapon = isWeapon
        self.editingEquipment = editingEquipment
        self.editingWeapon = editingWeapon
        
        // Initialize state variables with proper defensive checks
        if let equipment = editingEquipment, !isWeapon {
            // Editing existing equipment
            _itemName = State(initialValue: equipment.name.isEmpty ? "Unnamed Equipment" : equipment.name)
            _itemDescription = State(initialValue: equipment.equipmentDescription)
            _encumbrance = State(initialValue: max(0, equipment.encumbrance))
            _cost = State(initialValue: max(0, equipment.cost))
            _availability = State(initialValue: equipment.availability.isEmpty ? AvailabilityLevels.common : equipment.availability)
            _selectedQualities = State(initialValue: Set(equipment.qualities))
            _selectedFlaws = State(initialValue: Set(equipment.flaws))
            _selectedTraits = State(initialValue: Set(equipment.traits.map { $0.name }))
            // Set default weapon values for consistency
            _specialization = State(initialValue: WeaponSpecializations.none)
            _damage = State(initialValue: "")
            _range = State(initialValue: WeaponRanges.short)
            _magazine = State(initialValue: 0)
            _selectedWeaponTraits = State(initialValue: [])
            _selectedModifications = State(initialValue: [])
        } else if let weapon = editingWeapon, isWeapon {
            // Editing existing weapon
            _itemName = State(initialValue: weapon.name.isEmpty ? "Unnamed Weapon" : weapon.name)
            _itemDescription = State(initialValue: "") // Weapons don't have descriptions in equipment section
            _specialization = State(initialValue: weapon.specialization.isEmpty ? WeaponSpecializations.none : weapon.specialization)
            _damage = State(initialValue: weapon.damage)
            _range = State(initialValue: weapon.range.isEmpty ? WeaponRanges.short : weapon.range)
            _magazine = State(initialValue: max(0, weapon.magazine))
            _encumbrance = State(initialValue: max(0, weapon.encumbrance))
            _cost = State(initialValue: max(0, weapon.cost))
            _availability = State(initialValue: weapon.availability.isEmpty ? AvailabilityLevels.common : weapon.availability)
            _selectedQualities = State(initialValue: Set(weapon.qualities))
            _selectedFlaws = State(initialValue: Set(weapon.flaws))
            _selectedWeaponTraits = State(initialValue: Set(weapon.weaponTraits.map { $0.name }))
            _selectedModifications = State(initialValue: Set(weapon.modifications))
            // Set default equipment values for consistency
            _selectedTraits = State(initialValue: [])
        } else {
            // Default values for new items
            _itemName = State(initialValue: "")
            _itemDescription = State(initialValue: "")
            _encumbrance = State(initialValue: 0)
            _cost = State(initialValue: 0)
            _availability = State(initialValue: AvailabilityLevels.common)
            _selectedQualities = State(initialValue: [])
            _selectedFlaws = State(initialValue: [])
            _selectedTraits = State(initialValue: [])
            _specialization = State(initialValue: WeaponSpecializations.none)
            _damage = State(initialValue: "")
            _range = State(initialValue: WeaponRanges.short)
            _magazine = State(initialValue: 0)
            _selectedWeaponTraits = State(initialValue: [])
            _selectedModifications = State(initialValue: [])
        }
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Basic Information") {
                    TextField(isWeapon ? "Weapon Name" : "Equipment Name", text: $itemName)
                    TextField("Description", text: $itemDescription, axis: .vertical)
                        .lineLimit(3...6)
                }
                
                if isWeapon {
                    Section("Weapon Properties") {
                        Picker("Specialization", selection: $specialization) {
                            ForEach(WeaponSpecializations.all, id: \.self) { spec in
                                Text(spec).tag(spec)
                            }
                        }
                        
                        TextField("Damage", text: $damage)
                        
                        Picker("Range", selection: $range) {
                            ForEach(WeaponRanges.all, id: \.self) { rangeType in
                                Text(rangeType).tag(rangeType)
                            }
                        }
                        
                        HStack {
                            Text("Magazine")
                            Spacer()
                            Stepper("\(magazine)", value: $magazine, in: 0...999)
                        }
                    }
                }
                
                Section("Physical Properties") {
                    HStack {
                        Text("Encumbrance")
                        Spacer()
                        Stepper("\(encumbrance)", value: $encumbrance, in: 0...50)
                    }
                    
                    HStack {
                        Text("Cost")
                        Spacer()
                        TextField("Cost", value: $cost, format: .number)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .frame(width: 100)
                            .keyboardType(.numberPad)
                    }
                    
                    Picker("Availability", selection: $availability) {
                        ForEach(AvailabilityLevels.all, id: \.self) { level in
                            Text(level).tag(level)
                        }
                    }
                }
                
                Section("Qualities") {
                    ForEach(EquipmentQualities.all, id: \.self) { quality in
                        HStack {
                            Text(quality)
                            Spacer()
                            if selectedQualities.contains(quality) {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.blue)
                            }
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            if selectedQualities.contains(quality) {
                                selectedQualities.remove(quality)
                            } else {
                                selectedQualities.insert(quality)
                            }
                        }
                    }
                }
                
                Section("Flaws") {
                    ForEach(EquipmentFlaws.all, id: \.self) { flaw in
                        HStack {
                            Text(flaw)
                            Spacer()
                            if selectedFlaws.contains(flaw) {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.blue)
                            }
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            if selectedFlaws.contains(flaw) {
                                selectedFlaws.remove(flaw)
                            } else {
                                selectedFlaws.insert(flaw)
                            }
                        }
                    }
                }
                
                if isWeapon {
                    Section("Weapon Traits") {
                        ForEach(WeaponTraitNames.all, id: \.self) { trait in
                            HStack {
                                Text(trait)
                                Spacer()
                                if selectedWeaponTraits.contains(trait) {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.blue)
                                }
                            }
                            .contentShape(Rectangle())
                            .onTapGesture {
                                if selectedWeaponTraits.contains(trait) {
                                    selectedWeaponTraits.remove(trait)
                                } else {
                                    selectedWeaponTraits.insert(trait)
                                }
                            }
                        }
                    }
                    
                    Section("Modifications") {
                        ForEach(WeaponModifications.all, id: \.self) { modification in
                            HStack {
                                Text(modification)
                                Spacer()
                                if selectedModifications.contains(modification) {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.blue)
                                }
                            }
                            .contentShape(Rectangle())
                            .onTapGesture {
                                if selectedModifications.contains(modification) {
                                    selectedModifications.remove(modification)
                                } else {
                                    selectedModifications.insert(modification)
                                }
                            }
                        }
                    }
                } else {
                    Section("Equipment Traits") {
                        ForEach(EquipmentTraitNames.all, id: \.self) { trait in
                            HStack {
                                Text(trait)
                                Spacer()
                                if selectedTraits.contains(trait) {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.blue)
                                }
                            }
                            .contentShape(Rectangle())
                            .onTapGesture {
                                if selectedTraits.contains(trait) {
                                    selectedTraits.remove(trait)
                                } else {
                                    selectedTraits.insert(trait)
                                }
                            }
                        }
                    }
                }
                
                Section {
                    Text("Tap on items to select/deselect them for your \(isWeapon ? "weapon" : "equipment").")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .navigationTitle(editingEquipment != nil || editingWeapon != nil ? "Edit \(isWeapon ? "Weapon" : "Equipment")" : "Add \(isWeapon ? "Weapon" : "Equipment")")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(editingEquipment != nil || editingWeapon != nil ? "Save" : "Add") {
                        saveItem()
                    }
                    .disabled(itemName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
    
    private func saveItem() {
        let trimmedName = itemName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else { return }
        
        if isWeapon {
            let weapon = Weapon(
                name: trimmedName,
                specialization: specialization,
                damage: damage,
                range: range,
                magazine: magazine,
                encumbrance: encumbrance,
                availability: availability,
                cost: cost
            )
            
            // Set weapon traits
            weapon.weaponTraits = selectedWeaponTraits.map { WeaponTrait(name: $0) }
            weapon.modifications = Array(selectedModifications)
            weapon.qualities = Array(selectedQualities)
            weapon.flaws = Array(selectedFlaws)
            
            var weaponList = character.weaponList
            
            if let editingWeapon = editingWeapon {
                // Remove the old weapon and add the new one
                weaponList.removeAll { $0.name == editingWeapon.name }
            }
            
            weaponList.append(weapon)
            character.weaponList = weaponList
        } else {
            let equipment = Equipment(
                name: trimmedName,
                equipmentDescription: itemDescription,
                encumbrance: encumbrance,
                cost: cost,
                availability: availability
            )
            
            // Set equipment properties
            equipment.traits = selectedTraits.map { EquipmentTrait(name: $0) }
            equipment.qualities = Array(selectedQualities)
            equipment.flaws = Array(selectedFlaws)
            
            var equipmentList = character.equipmentList
            
            if let editingEquipment = editingEquipment {
                // Remove the old equipment and add the new one
                equipmentList.removeAll { $0.name == editingEquipment.name }
            }
            
            equipmentList.append(equipment)
            character.equipmentList = equipmentList
        }
        
        character.lastModified = Date()
        store.saveChanges()
        dismiss()
    }
}

// MARK: - Psychic Powers Tab

struct PsychicPowersTab: View {
    let character: any BaseCharacter
    @ObservedObject var store: CharacterStore
    @Binding var isEditMode: Bool
    
    var imperiumCharacter: ImperiumCharacter? {
        return character as? ImperiumCharacter
    }
    
    var body: some View {
        NavigationView {
            List {
                if let imperium = imperiumCharacter {
                    ForEach(imperium.psychicPowers, id: \.self) { power in
                        Text(power)
                    }
                } else {
                    Text("Psychic powers not available for this character type")
                        .foregroundColor(.secondary)
                }
            }
            .navigationTitle("Psychic Powers")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

// MARK: - Status Popup View

struct StatusPopupView: View {
    @Binding var character: ImperiumCharacter
    var store: CharacterStore
    @Environment(\.dismiss) private var dismiss
    
    // Local state to force UI updates
    @State private var wounds: Int = 0
    @State private var corruption: Int = 0
    @State private var fate: Int = 0
    @State private var spentFate: Int = 0
    
    var body: some View {
        NavigationStack {
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
            .onAppear {
                // Initialize state from character
                wounds = character.wounds
                corruption = character.corruption
                fate = character.fate
                spentFate = character.spentFate
            }
        }
    }
    
    private func updateCharacter() {
        character.wounds = wounds
        character.corruption = corruption
        character.fate = fate
        character.spentFate = spentFate
        character.lastModified = Date()
        store.saveChanges()
    }
}

// MARK: - Injuries Popup View

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

// MARK: - Conditions Popup View

struct ConditionsPopupView: View {
    @Binding var character: ImperiumCharacter
    var store: CharacterStore
    @Environment(\.dismiss) private var dismiss
    @State private var showingAddConditionSheet = false
    
    var body: some View {
        NavigationStack {
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
            .navigationTitle("Conditions")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .sheet(isPresented: $showingAddConditionSheet) {
            AddConditionSheet(character: $character, store: store)
        }
    }
    
    private func removeConditions(at offsets: IndexSet) {
        var conditions = character.conditionsList
        conditions.remove(atOffsets: offsets)
        character.conditionsList = conditions
        character.lastModified = Date()
        store.saveChanges()
    }
}

struct ConditionRowView: View {
    let condition: Condition
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(condition.name)
                .font(.headline)
                .foregroundColor(.primary)
            
            Text(condition.description)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.leading)
        }
        .padding(.vertical, 4)
    }
}

struct AddConditionSheet: View {
    @Binding var character: ImperiumCharacter
    var store: CharacterStore
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            List(ConditionDefinitions.allConditions) { condition in
                Button(action: {
                    var conditions = character.conditionsList
                    conditions.append(condition)
                    character.conditionsList = conditions
                    character.lastModified = Date()
                    store.saveChanges()
                    dismiss()
                }) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(condition.name)
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        Text(condition.description)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.leading)
                    }
                    .padding(.vertical, 4)
                }
                .buttonStyle(.plain)
            }
            .navigationTitle("Add Condition")
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

#Preview {
    let character = ImperiumCharacter()
    character.name = "Inquisitor Vex"
    character.faction = "Inquisition"
    character.role = "Acolyte"
    character.homeworld = "Hive World"
    character.maxWounds = 15
    character.wounds = 12
    character.corruption = 5
    
    let binding = Binding<any BaseCharacter>(
        get: { character },
        set: { _ in }
    )
    
    return NavigationStack {
        CharacterDetailView(character: binding, store: CharacterStore())
    }
}
