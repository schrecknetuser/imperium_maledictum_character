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
                        
                        if imperium.thrones > 0 {
                            DetailRow(title: "Wealth", value: "\(imperium.thrones) Thrones")
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
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 16) {
                CharacteristicDisplay("Weapon Skill", value: character.weaponSkill)
                CharacteristicDisplay("Ballistic Skill", value: character.ballisticSkill)
                CharacteristicDisplay("Strength", value: character.strength)
                CharacteristicDisplay("Toughness", value: character.toughness)
                CharacteristicDisplay("Agility", value: character.agility)
                CharacteristicDisplay("Intelligence", value: character.intelligence)
                CharacteristicDisplay("Willpower", value: character.willpower)
                CharacteristicDisplay("Fellowship", value: character.fellowship)
                CharacteristicDisplay("Influence", value: character.influence)
            }
            .padding()
        }
    }
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
                    ForEach(imperium.talents, id: \.self) { talent in
                        Text(talent)
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
                    ForEach(imperium.equipment, id: \.self) { item in
                        Text(item)
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