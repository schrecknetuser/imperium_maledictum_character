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
    @State private var showingEditSheet = false
    
    var imperiumCharacter: ImperiumCharacter? {
        return character as? ImperiumCharacter
    }
    
    var body: some View {
        TabView(selection: $selectedTab) {
            OverviewTab(character: $character, store: store)
                .tabItem {
                    Image(systemName: "person.circle")
                    Text("Overview")
                }
                .tag(0)
            
            CharacteristicsTab(character: character)
                .tabItem {
                    Image(systemName: "chart.bar")
                    Text("Stats")
                }
                .tag(1)
            
            SkillsTab(character: character, store: store)
                .tabItem {
                    Image(systemName: "brain.head.profile")
                    Text("Skills")
                }
                .tag(2)
            
            TalentsTab(character: character, store: store)
                .tabItem {
                    Image(systemName: "star.circle")
                    Text("Talents")
                }
                .tag(3)
            
            EquipmentTab(character: character, store: store)
                .tabItem {
                    Image(systemName: "bag")
                    Text("Equipment")
                }
                .tag(4)
            
            if imperiumCharacter?.role.lowercased().contains("psyker") == true {
                PsychicPowersTab(character: character, store: store)
                    .tabItem {
                        Image(systemName: "brain")
                        Text("Psychic")
                    }
                    .tag(5)
            }
        }
        .navigationTitle(character.name.isEmpty ? "Unnamed Character" : character.name)
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Edit") {
                    showingEditSheet = true
                }
            }
        }
        .sheet(isPresented: $showingEditSheet) {
            EditCharacterSheet(character: $character, store: store)
        }
    }
}

// MARK: - Overview Tab

struct OverviewTab: View {
    @Binding var character: any BaseCharacter
    @ObservedObject var store: CharacterStore
    @State private var showingStatusPopup = false
    @State private var showingInjuriesPopup = false
    
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
                            Text(character.name.isEmpty ? "Unnamed Character" : character.name)
                                .font(.title)
                                .fontWeight(.bold)
                            
                            if !character.faction.isEmpty {
                                Text(character.faction)
                                    .font(.headline)
                                    .foregroundColor(.secondary)
                            }
                            
                            if !character.role.isEmpty {
                                Text(character.role)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            
                            if let imperium = imperiumCharacter, !imperium.homeworld.isEmpty {
                                Text(imperium.homeworld)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        Spacer()
                    }
                    
                    if !character.campaign.isEmpty {
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
                        
                        Text("Experience points represent your character's growth and development through adventures.")
                            .font(.caption)
                            .foregroundColor(.secondary)
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
                                Text("\(skill.advances)")
                                    .font(.caption)
                                    .frame(width: 40, alignment: .center)
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
                                Text("\(specialization.advances)")
                                    .font(.caption)
                                    .frame(width: 40, alignment: .center)
                                Text("\(specialization.totalValue)")
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
            }
            .padding()
        }
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
                if advances > 0 {
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

struct SkillsTab: View {
    let character: any BaseCharacter
    @ObservedObject var store: CharacterStore
    
    var imperiumCharacter: ImperiumCharacter? {
        return character as? ImperiumCharacter
    }
    
    var body: some View {
        NavigationView {
            List {
                if let imperium = imperiumCharacter {
                    ForEach(Array(imperium.skills.keys.sorted()), id: \.self) { skill in
                        HStack {
                            Text(skill)
                            Spacer()
                            Text("\(imperium.skills[skill] ?? 0)")
                                .foregroundColor(.secondary)
                        }
                    }
                } else {
                    Text("Skills not available for this character type")
                        .foregroundColor(.secondary)
                }
            }
            .navigationTitle("Skills")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

// MARK: - Talents Tab

struct TalentsTab: View {
    let character: any BaseCharacter
    @ObservedObject var store: CharacterStore
    
    var imperiumCharacter: ImperiumCharacter? {
        return character as? ImperiumCharacter
    }
    
    var body: some View {
        NavigationView {
            List {
                if let imperium = imperiumCharacter {
                    ForEach(imperium.talentNames, id: \.self) { talent in
                        Text(talent)
                    }
                    
                    if imperium.talentNames.isEmpty {
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
    }
}

// MARK: - Equipment Tab

struct EquipmentDisplayItem {
    let baseName: String
    let modifications: [String]
    let traits: [String]
    
    init(from fullName: String) {
        var working = fullName.trimmingCharacters(in: .whitespacesAndNewlines)
        var modifications: [String] = []
        var traits: [String] = []
        
        // Known traits that should be separated (order matters for longest-first matching)
        let knownTraits = ["Master Crafted", "Mono-Edge", "Shoddy", "Ugly", "Bulky", "Lightweight", "Ornamental", "Durable", "Razor Sharp", "Well Balanced", "Power Field"]
        
        // First, extract content from parentheses
        let modificationPattern = #"\(([^)]+)\)"#
        var parenthesesContent: [String] = []
        
        if let regex = try? NSRegularExpression(pattern: modificationPattern) {
            let matches = regex.matches(in: working, range: NSRange(working.startIndex..., in: working))
            for match in matches.reversed() {
                if let range = Range(match.range(at: 1), in: working) {
                    let content = String(working[range]).trimmingCharacters(in: .whitespacesAndNewlines)
                    parenthesesContent.append(content)
                }
                if let fullRange = Range(match.range, in: working) {
                    working.removeSubrange(fullRange)
                    working = working.trimmingCharacters(in: .whitespacesAndNewlines)
                }
            }
        }
        
        // Now extract traits from both the main name and parentheses content
        for trait in knownTraits {
            // Check main name
            if working.lowercased().contains(trait.lowercased()) {
                traits.append(trait)
                let regex = try! NSRegularExpression(pattern: "\\b" + NSRegularExpression.escapedPattern(for: trait) + "\\b", options: .caseInsensitive)
                working = regex.stringByReplacingMatches(in: working, options: [], range: NSRange(location: 0, length: working.count), withTemplate: "")
                working = working.trimmingCharacters(in: .whitespacesAndNewlines)
                working = working.replacingOccurrences(of: "  +", with: " ", options: .regularExpression)
            }
            
            // Check parentheses content and separate traits from other modifications
            parenthesesContent = parenthesesContent.compactMap { content in
                if content.lowercased() == trait.lowercased() {
                    if !traits.contains(trait) {
                        traits.append(trait)
                    }
                    return nil // Remove this content as it's now a trait
                } else {
                    return content
                }
            }
        }
        
        // Remaining parentheses content are modifications
        modifications = parenthesesContent.filter { !$0.isEmpty }
        
        self.baseName = working.trimmingCharacters(in: .whitespacesAndNewlines)
        self.modifications = modifications
        self.traits = traits
    }
    
    var displayText: String {
        var result = baseName
        if !modifications.isEmpty {
            result += " (" + modifications.joined(separator: ", ") + ")"
        }
        return result
    }
    
    var traitsText: String {
        return traits.isEmpty ? "" : "Traits: " + traits.joined(separator: ", ")
    }
}

struct EquipmentTab: View {
    let character: any BaseCharacter
    @ObservedObject var store: CharacterStore
    
    var imperiumCharacter: ImperiumCharacter? {
        return character as? ImperiumCharacter
    }
    
    var body: some View {
        NavigationView {
            List {
                if let imperium = imperiumCharacter {
                    Section("Equipment") {
                        ForEach(imperium.equipmentNames, id: \.self) { item in
                            let equipmentItem = EquipmentDisplayItem(from: item)
                            VStack(alignment: .leading, spacing: 2) {
                                Text(equipmentItem.displayText)
                                    .font(.body)
                                if !equipmentItem.traitsText.isEmpty {
                                    Text(equipmentItem.traitsText)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                        .italic()
                                }
                            }
                        }
                        
                        if imperium.equipmentNames.isEmpty {
                            Text("No equipment")
                                .foregroundColor(.secondary)
                                .italic()
                        }
                    }
                    
                    Section("Weapons") {
                        ForEach(imperium.weaponNames, id: \.self) { weapon in
                            let weaponItem = EquipmentDisplayItem(from: weapon)
                            VStack(alignment: .leading, spacing: 2) {
                                Text(weaponItem.displayText)
                                    .font(.body)
                                if !weaponItem.traitsText.isEmpty {
                                    Text(weaponItem.traitsText)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                        .italic()
                                }
                            }
                        }
                        
                        if imperium.weaponNames.isEmpty {
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
        }
    }
}

// MARK: - Psychic Powers Tab

struct PsychicPowersTab: View {
    let character: any BaseCharacter
    @ObservedObject var store: CharacterStore
    
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

// MARK: - Edit Character Sheet

struct EditCharacterSheet: View {
    @Binding var character: any BaseCharacter
    @ObservedObject var store: CharacterStore
    @Environment(\.dismiss) private var dismiss
    
    var imperiumCharacter: ImperiumCharacter? {
        return character as? ImperiumCharacter
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Basic Information") {
                    TextField("Name", text: $character.name)
                    TextField("Player", text: $character.player)
                    TextField("Campaign", text: $character.campaign)
                }
                
                Section("Faction & Role") {
                    TextField("Faction", text: $character.faction)
                    TextField("Role", text: $character.role)
                    
                    if let imperium = imperiumCharacter {
                        let homeworldBinding = Binding<String>(
                            get: { imperium.homeworld },
                            set: { imperium.homeworld = $0 }
                        )
                        TextField("Homeworld", text: homeworldBinding)
                    }
                }
                
                if let imperium = imperiumCharacter {
                    Section("Character Information") {
                        let shortTermGoalBinding = Binding<String>(
                            get: { imperium.shortTermGoal },
                            set: { imperium.shortTermGoal = $0 }
                        )
                        TextField("Short-term Goal", text: shortTermGoalBinding, axis: .vertical)
                            .lineLimit(2...4)
                        
                        let longTermGoalBinding = Binding<String>(
                            get: { imperium.longTermGoal },
                            set: { imperium.longTermGoal = $0 }
                        )
                        TextField("Long-term Goal", text: longTermGoalBinding, axis: .vertical)
                            .lineLimit(2...4)
                        
                        let descriptionBinding = Binding<String>(
                            get: { imperium.characterDescription },
                            set: { imperium.characterDescription = $0 }
                        )
                        TextField("Character Description", text: descriptionBinding, axis: .vertical)
                            .lineLimit(3...6)
                    }
                }
                
                Section("Status") {
                    HStack {
                        Text("Wounds")
                        Spacer()
                        TextField("Current", value: $character.wounds, format: .number)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .frame(width: 60)
                        Text("/")
                        if let imperium = imperiumCharacter {
                            Text("\(imperium.calculateMaxWounds())")
                                .frame(width: 60)
                        } else {
                            TextField("Max", value: $character.maxWounds, format: .number)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .frame(width: 60)
                        }
                    }
                    
                    HStack {
                        Text("Corruption")
                        Spacer()
                        TextField("Corruption", value: $character.corruption, format: .number)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .frame(width: 80)
                        
                        if let imperium = imperiumCharacter {
                            Text("/ 100 (Threshold: \(imperium.calculateCorruptionThreshold()))")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    if let imperium = imperiumCharacter {
                        HStack {
                            Text("Critical Wounds")
                            Spacer()
                            let criticalWoundsBinding = Binding<Int>(
                                get: { imperium.criticalWounds },
                                set: { imperium.criticalWounds = $0 }
                            )
                            TextField("Count", value: criticalWoundsBinding, format: .number)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .frame(width: 60)
                        }
                    }
                }
            }
            .navigationTitle("Edit Character")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        store.saveChanges()
                        dismiss()
                    }
                }
            }
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
    @State private var totalExperience: Int = 0
    @State private var spentExperience: Int = 0
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Character Status") {
                    // Wounds
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Wounds")
                            .font(.headline)
                        
                        HStack {
                            Button {
                                if wounds > 0 {
                                    wounds -= 1
                                    updateCharacter()
                                }
                            } label: {
                                Image(systemName: "minus.circle")
                                    .font(.title2)
                                    .foregroundColor(.red)
                            }
                            .disabled(wounds <= 0)
                            
                            Spacer()
                            
                            Text("\(wounds)")
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            Spacer()
                            
                            Button {
                                if wounds < character.calculateMaxWounds() {
                                    wounds += 1
                                    updateCharacter()
                                }
                            } label: {
                                Image(systemName: "plus.circle")
                                    .font(.title2)
                                    .foregroundColor(.red)
                            }
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
                            Button {
                                if corruption > 0 {
                                    corruption -= 1
                                    updateCharacter()
                                }
                            } label: {
                                Image(systemName: "minus.circle")
                                    .font(.title2)
                                    .foregroundColor(.purple)
                            }
                            .disabled(corruption <= 0)
                            
                            Spacer()
                            
                            Text("\(corruption)")
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            Spacer()
                            
                            Button {
                                corruption += 1
                                updateCharacter()
                            } label: {
                                Image(systemName: "plus.circle")
                                    .font(.title2)
                                    .foregroundColor(.purple)
                            }
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
                            Button {
                                if fate > 0 {
                                    fate -= 1
                                    // Adjust spent fate if it exceeds current fate
                                    if spentFate > fate {
                                        spentFate = fate
                                    }
                                    updateCharacter()
                                }
                            } label: {
                                Image(systemName: "minus.circle")
                                    .font(.title2)
                                    .foregroundColor(.yellow)
                            }
                            .disabled(fate <= 0)
                            
                            Spacer()
                            
                            Text("\(fate)")
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            Spacer()
                            
                            Button {
                                fate += 1
                                updateCharacter()
                            } label: {
                                Image(systemName: "plus.circle")
                                    .font(.title2)
                                    .foregroundColor(.yellow)
                            }
                        }
                    }
                    
                    // Spent Fate
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Spent Fate")
                            .font(.headline)
                        
                        HStack {
                            Button {
                                if spentFate > 0 {
                                    spentFate -= 1
                                    updateCharacter()
                                }
                            } label: {
                                Image(systemName: "minus.circle")
                                    .font(.title2)
                                    .foregroundColor(.orange)
                            }
                            .disabled(spentFate <= 0)
                            
                            Spacer()
                            
                            Text("\(spentFate)")
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            Spacer()
                            
                            Button {
                                if spentFate < fate {
                                    spentFate += 1
                                    updateCharacter()
                                }
                            } label: {
                                Image(systemName: "plus.circle")
                                    .font(.title2)
                                    .foregroundColor(.orange)
                            }
                            .disabled(spentFate >= fate)
                        }
                        
                        Text("Available: \(fate - spentFate)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Section("Experience") {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Total Experience")
                            .font(.headline)
                        
                        HStack {
                            Button {
                                if totalExperience > 0 {
                                    totalExperience -= 1
                                    // Adjust spent experience if it exceeds total
                                    if spentExperience > totalExperience {
                                        spentExperience = totalExperience
                                    }
                                    updateCharacter()
                                }
                            } label: {
                                Image(systemName: "minus.circle")
                                    .font(.title2)
                                    .foregroundColor(.blue)
                            }
                            .disabled(totalExperience <= 0)
                            
                            Spacer()
                            
                            Text("\(totalExperience)")
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            Spacer()
                            
                            Button {
                                totalExperience += 1
                                updateCharacter()
                            } label: {
                                Image(systemName: "plus.circle")
                                    .font(.title2)
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Spent Experience")
                            .font(.headline)
                        
                        HStack {
                            Button {
                                if spentExperience > 0 {
                                    spentExperience -= 1
                                    updateCharacter()
                                }
                            } label: {
                                Image(systemName: "minus.circle")
                                    .font(.title2)
                                    .foregroundColor(.gray)
                            }
                            .disabled(spentExperience <= 0)
                            
                            Spacer()
                            
                            Text("\(spentExperience)")
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            Spacer()
                            
                            Button {
                                if spentExperience < totalExperience {
                                    spentExperience += 1
                                    updateCharacter()
                                }
                            } label: {
                                Image(systemName: "plus.circle")
                                    .font(.title2)
                                    .foregroundColor(.gray)
                            }
                            .disabled(spentExperience >= totalExperience)
                        }
                        
                        Text("Available: \(totalExperience - spentExperience)")
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
                totalExperience = character.totalExperience
                spentExperience = character.spentExperience
            }
        }
    }
    
    private func updateCharacter() {
        character.wounds = wounds
        character.corruption = corruption
        character.fate = fate
        character.spentFate = spentFate
        character.totalExperience = totalExperience
        character.spentExperience = spentExperience
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
