//
//  CharacterStore.swift
//  ImperiumMaledictumCharacter
//
//  Created by User on 11.01.2025.
//

import Foundation
import SwiftData
import Combine

@MainActor
class CharacterStore: ObservableObject {
    @Published var characters: [AnyCharacter] = []
    
    private var modelContext: ModelContext?
    
    init() {
        loadCharacters()
    }
    
    func setModelContext(_ context: ModelContext) {
        self.modelContext = context
        loadCharacters()
    }
    
    private func loadCharacters() {
        guard let context = modelContext else { return }
        
        do {
            let descriptor = FetchDescriptor<ImperiumCharacter>(
                sortBy: [SortDescriptor(\.name)]
            )
            let imperiumCharacters = try context.fetch(descriptor)
            
            characters = imperiumCharacters.map { AnyCharacter(character: $0) }
        } catch {
            print("Failed to load characters: \(error)")
            characters = []
        }
    }
    
    func addCharacter(_ character: any BaseCharacter) {
        guard let context = modelContext else { return }
        
        if let imperiumChar = character as? ImperiumCharacter {
            context.insert(imperiumChar)
            characters.append(AnyCharacter(character: imperiumChar))
            
            do {
                try context.save()
            } catch {
                print("Failed to save character: \(error)")
            }
        }
    }
    
    func deleteCharacter(at offsets: IndexSet) {
        guard let context = modelContext else { return }
        
        for index in offsets {
            if index < characters.count {
                let characterToDelete = characters[index]
                
                // Remove from SwiftData
                if let imperiumChar = characterToDelete.character as? ImperiumCharacter {
                    context.delete(imperiumChar)
                }
                
                // Remove from local array
                characters.remove(at: index)
            }
        }
        
        do {
            try context.save()
        } catch {
            print("Failed to delete character: \(error)")
        }
    }
    
    func deleteCharacter(_ character: any BaseCharacter) {
        guard let context = modelContext else { return }
        
        // Find the character in the array and remove it
        if let index = characters.firstIndex(where: { $0.character.id == character.id }) {
            let characterToDelete = characters[index]
            
            // Remove from SwiftData
            if let imperiumChar = characterToDelete.character as? ImperiumCharacter {
                context.delete(imperiumChar)
            }
            
            // Remove from local array
            characters.remove(at: index)
            
            do {
                try context.save()
            } catch {
                print("Failed to delete character: \(error)")
            }
        }
    }
    
    func archiveCharacter(_ character: any BaseCharacter) {
        character.isArchived = true
        saveChanges()
    }
    
    func unarchiveCharacter(_ character: any BaseCharacter) {
        character.isArchived = false
        saveChanges()
    }
    
    func saveChanges() {
        guard let context = modelContext else { return }
        
        do {
            try context.save()
        } catch {
            print("Failed to save changes: \(error)")
        }
    }
    
    func saveCharacterWithChangeTracking(_ character: ImperiumCharacter, originalCharacter: ImperiumCharacter) {
        // Log changes if any exist
        character.logChanges(originalCharacter: originalCharacter)
        
        // Save to SwiftData
        saveChanges()
    }
    
    func saveCharacterWithAutoChangeTracking(_ character: ImperiumCharacter, originalSnapshot: CharacterSnapshot) {
        // Create a temporary character with the snapshot data for change comparison
        let originalCharacter = ImperiumCharacter()
        originalSnapshot.applyTo(originalCharacter)
        
        // Log changes if any exist
        character.logChanges(originalCharacter: originalCharacter)
        
        // Save to SwiftData
        saveChanges()
    }
    
    func createSnapshot(of character: ImperiumCharacter) -> CharacterSnapshot {
        return CharacterSnapshot(from: character)
    }
    
    // MARK: - Character Management
    
    func createNewCharacter() -> ImperiumCharacter {
        let character = ImperiumCharacter()
        return character
    }
    
    func getCharactersInCreation() -> [AnyCharacter] {
        return characters.filter { !$0.character.isCreationComplete }
    }
    
    func getCompletedCharacters() -> [AnyCharacter] {
        return characters.filter { $0.character.isCreationComplete }
    }
    
    func getActiveCharacters() -> [AnyCharacter] {
        return characters.filter { $0.character.isCreationComplete && !$0.character.isArchived }
    }
    
    func getArchivedCharacters() -> [AnyCharacter] {
        return characters.filter { $0.character.isArchived }
    }
    
    // MARK: - Campaign Management
    
    func getCampaigns() -> [String] {
        let campaigns = Set(characters.map { $0.character.campaign })
        return Array(campaigns).filter { !$0.isEmpty }.sorted()
    }
    
    func getCharacters(inCampaign campaign: String) -> [AnyCharacter] {
        return characters.filter { $0.character.campaign == campaign }
    }
    
    // MARK: - Search and Filter
    
    func searchCharacters(query: String) -> [AnyCharacter] {
        if query.isEmpty {
            return characters
        }
        
        let lowercasedQuery = query.lowercased()
        return characters.filter { character in
            character.character.name.lowercased().contains(lowercasedQuery) ||
            character.character.player.lowercased().contains(lowercasedQuery) ||
            character.character.campaign.lowercased().contains(lowercasedQuery) ||
            character.character.faction.lowercased().contains(lowercasedQuery) ||
            character.character.role.lowercased().contains(lowercasedQuery)
        }
    }
    
    func filterCharacters(byFaction faction: String) -> [AnyCharacter] {
        if faction.isEmpty {
            return characters
        }
        return characters.filter { $0.character.faction == faction }
    }
    
    func filterCharacters(byRole role: String) -> [AnyCharacter] {
        if role.isEmpty {
            return characters
        }
        return characters.filter { $0.character.role == role }
    }
    
    // MARK: - Statistics
    
    func getCharacterCount() -> Int {
        return characters.count
    }
    
    func getActiveCharacterCount() -> Int {
        return getActiveCharacters().count
    }
    
    func getArchivedCharacterCount() -> Int {
        return getArchivedCharacters().count
    }
    
    func getCharactersInCreationCount() -> Int {
        return getCharactersInCreation().count
    }
}