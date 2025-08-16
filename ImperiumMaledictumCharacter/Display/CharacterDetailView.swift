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
            OverviewTab(character: character)
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
    let character: any BaseCharacter
    
    var imperiumCharacter: ImperiumCharacter? {
        return character as? ImperiumCharacter
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
                
                // Status Overview
                VStack(alignment: .leading, spacing: 12) {
                    Text("Status")
                        .font(.headline)
                    
                    HStack(spacing: 20) {
                        StatusBox(title: "Wounds", current: character.wounds, maximum: character.maxWounds, color: .red)
                        StatusBox(title: "Corruption", current: character.corruption, maximum: 100, color: .purple)
                        
                        if let imperium = imperiumCharacter {
                            StatusBox(title: "Stress", current: imperium.stress, maximum: 100, color: .orange)
                            StatusBox(title: "Fate", current: imperium.fate, maximum: 10, color: .blue)
                        }
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                
                // Character Details
                if let imperium = imperiumCharacter {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Details")
                            .font(.headline)
                        
                        if !imperium.homeworld.isEmpty {
                            DetailRow(title: "Homeworld", value: imperium.homeworld)
                        }
                        
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
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                }
            }
            .padding()
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

struct CharacteristicRowData {
    let abbreviation: String
    let name: String
    let baseValue: Int
    let advances: Int
    let totalValue: Int
}

struct SkillRowData {
    let name: String
    let characteristicAbbreviation: String
    let advances: Int
    let totalValue: Int
}

struct SpecializationRowData {
    let name: String
    let skillName: String
    let advances: Int
    let totalValue: Int
}

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
        
        // Extract traits first (before parentheses)
        for trait in knownTraits {
            if working.lowercased().contains(trait.lowercased()) {
                traits.append(trait)
                // Remove trait from working string (case insensitive)
                let regex = try! NSRegularExpression(pattern: "\\b" + NSRegularExpression.escapedPattern(for: trait) + "\\b", options: .caseInsensitive)
                working = regex.stringByReplacingMatches(in: working, options: [], range: NSRange(location: 0, length: working.count), withTemplate: "")
                working = working.trimmingCharacters(in: .whitespacesAndNewlines)
                // Clean up multiple spaces
                working = working.replacingOccurrences(of: "  +", with: " ", options: .regularExpression)
            }
        }
        
        // Extract modifications (typically in parentheses)
        let modificationPattern = #"\(([^)]+)\)"#
        if let regex = try? NSRegularExpression(pattern: modificationPattern) {
            let matches = regex.matches(in: working, range: NSRange(working.startIndex..., in: working))
            for match in matches.reversed() {
                if let range = Range(match.range(at: 1), in: working) {
                    let modification = String(working[range])
                    modifications.append(modification)
                }
                if let fullRange = Range(match.range, in: working) {
                    working.removeSubrange(fullRange)
                    working = working.trimmingCharacters(in: .whitespacesAndNewlines)
                }
            }
        }
        
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
                }
                
                Section("Status") {
                    HStack {
                        Text("Wounds")
                        Spacer()
                        TextField("Current", value: $character.wounds, format: .number)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .frame(width: 60)
                        Text("/")
                        TextField("Max", value: $character.maxWounds, format: .number)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .frame(width: 60)
                    }
                    
                    HStack {
                        Text("Corruption")
                        Spacer()
                        TextField("Corruption", value: $character.corruption, format: .number)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .frame(width: 80)
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
