//
//  ContentView.swift
//  ImperiumMaledictumCharacter
//
//  Created by User on 11.01.2025.
//

import SwiftUI
import SwiftData

struct CharacterRow: View {
    let character: any BaseCharacter
    
    var body: some View {
        HStack {
            Text(character.characterType.symbol)
                .font(.title2)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(character.name.isEmpty ? "Unnamed Character" : character.name)
                    .font(.headline)
                
                HStack {
                    if !character.faction.isEmpty {
                        Text(character.faction)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    if !character.role.isEmpty {
                        Text("• \(character.role)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                
                if !character.campaign.isEmpty {
                    Text("Campaign: \(character.campaign)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            if !character.isCreationComplete {
                VStack(alignment: .trailing) {
                    Text("In Creation")
                        .font(.caption)
                        .foregroundColor(.orange)
                    Text("Stage \(character.creationProgress + 1)/\(CreationStages.totalStages)")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(.vertical, 2)
    }
}

struct CharacterListView: View {
    @ObservedObject var store: CharacterStore
    @State private var showingCreationWizard = false
    @State private var characterToResume: IdentifiableCharacter? = nil
    @State private var expandedCampaigns: [String: Bool] = [:]
    @State private var showingDeleteConfirmation = false
    @State private var characterToDelete: any BaseCharacter = ImperiumCharacter() {
        didSet {
            showingDeleteConfirmation = true
        }
    }
    
    var body: some View {
        List {
            // Characters in creation section
            let charactersInCreation = store.getCharactersInCreation()
            if !charactersInCreation.isEmpty {
                Section {
                    ForEach(charactersInCreation.indices, id: \.self) { index in
                        let character = charactersInCreation[index].character
                        
                        Button(action: {
                            characterToResume = IdentifiableCharacter(character: character)
                        }) {
                            CharacterRow(character: character)
                        }
                        .foregroundColor(.primary)
                        .swipeActions(edge: .trailing) {
                            Button {
                                characterToDelete = character
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                            .tint(.red)
                        }
                    }
                    .onDelete { offsets in
                        let indicesToDelete = IndexSet(offsets.compactMap { offset in
                            let characterId = charactersInCreation[offset].id
                            return store.characters.firstIndex { $0.id == characterId }
                        })
                        store.deleteCharacter(at: indicesToDelete)
                    }
                } header: {
                    Text("Characters in Creation")
                        .font(.headline)
                        .foregroundColor(.orange)
                }
            }
            
            // Active characters grouped by campaign
            let activeCharacters = store.getActiveCharacters()
            let groupedCharacters = groupCharactersByCampaign(activeCharacters)
            
            ForEach(groupedCharacters, id: \.campaign) { group in
                Section {
                    ForEach(group.characters.indices, id: \.self) { index in
                        let character = group.characters[index].character
                        let characterBinding = Binding<any BaseCharacter>(
                            get: { character },
                            set: { _ in }
                        )
                        
                        NavigationLink(destination: CharacterDetailView(character: characterBinding, store: store)) {
                            CharacterRow(character: character)
                        }
                        .swipeActions(edge: .trailing) {
                            Button {
                                characterToDelete = character
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                            .tint(.red)
                            
                            Button {
                                store.archiveCharacter(character)
                            } label: {
                                Label("Archive", systemImage: "archivebox")
                            }
                            .tint(.orange)
                        }
                    }
                    .onDelete { offsets in
                        let indicesToDelete = IndexSet(offsets.compactMap { offset in
                            let characterId = group.characters[offset].id
                            return store.characters.firstIndex { $0.id == characterId }
                        })
                        store.deleteCharacter(at: indicesToDelete)
                    }
                } header: {
                    Text(group.campaign.isEmpty ? "No Campaign" : group.campaign)
                        .font(.headline)
                        .foregroundColor(.primary)
                }
            }
            
            // Archived characters section
            let archivedCharacters = store.getArchivedCharacters()
            if !archivedCharacters.isEmpty {
                Section {
                    ForEach(archivedCharacters.indices, id: \.self) { index in
                        let character = archivedCharacters[index].character
                        let characterBinding = Binding<any BaseCharacter>(
                            get: { character },
                            set: { _ in }
                        )
                        
                        NavigationLink(destination: CharacterDetailView(character: characterBinding, store: store)) {
                            CharacterRow(character: character)
                        }
                        .swipeActions(edge: .trailing) {
                            Button {
                                characterToDelete = character
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                            .tint(.red)
                            
                            Button {
                                store.unarchiveCharacter(character)
                            } label: {
                                Label("Unarchive", systemImage: "archivebox.fill")
                            }
                            .tint(.green)
                        }
                    }
                    .onDelete { offsets in
                        let indicesToDelete = IndexSet(offsets.compactMap { offset in
                            let characterId = archivedCharacters[offset].id
                            return store.characters.firstIndex { $0.id == characterId }
                        })
                        store.deleteCharacter(at: indicesToDelete)
                    }
                } header: {
                    Text("Archive (\(archivedCharacters.count))")
                        .font(.headline)
                        .foregroundColor(.secondary)
                }
            }
        }
        .fullScreenCover(isPresented: $showingCreationWizard) {
            CharacterCreationWizard(store: store)
        }
        .fullScreenCover(item: $characterToResume) { identifiable in
            CharacterCreationWizard(store: store, existingCharacter: identifiable.character)
        }
        .alert("Delete Character", isPresented: $showingDeleteConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                store.deleteCharacter(characterToDelete)
            }
        } message: {
            Text("Are you sure you want to delete '\(characterToDelete.name.isEmpty ? "Unnamed Character" : characterToDelete.name)'? This action cannot be undone.")
        }
    }
    
    private func groupCharactersByCampaign(_ characters: [AnyCharacter]) -> [(campaign: String, characters: [AnyCharacter])] {
        let grouped = Dictionary(grouping: characters) { character in
            character.character.campaign.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        
        let noCampaign = grouped[""] ?? []
        let campaignGroups = grouped.filter { $0.key != "" }
        
        var result: [(campaign: String, characters: [AnyCharacter])] = []
        
        if !noCampaign.isEmpty {
            result.append((campaign: "", characters: noCampaign.sorted { $0.character.name < $1.character.name }))
        }
        
        let sortedCampaigns = campaignGroups.keys.sorted()
        for campaign in sortedCampaigns {
            let characters = campaignGroups[campaign]!.sorted { $0.character.name < $1.character.name }
            result.append((campaign: campaign, characters: characters))
        }
        
        return result
    }
}

struct ContentView: View {
    @StateObject private var store = CharacterStore()
    @State private var showingAddSheet = false
    @Environment(\.modelContext) private var modelContext
    
    var body: some View {
        NavigationStack {
            CharacterListView(store: store)
                .navigationTitle("Imperium Characters")
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: { showingAddSheet = true }) {
                            Image(systemName: "plus")
                        }
                    }
                }
                .fullScreenCover(isPresented: $showingAddSheet) {
                    CharacterCreationWizard(store: store)
                }
        }
        .onAppear {
            store.setModelContext(modelContext)
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: ImperiumCharacter.self, inMemory: true)
}