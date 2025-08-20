//
//  StatusPopupView.swift
//  ImperiumMaledictumCharacter
//
//  Created by User on 11.01.2025.
//

import SwiftUI

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
        store.saveChanges()
    }
}