//
//  OverviewTabView.swift
//  ImperiumMaledictumCharacter
//
//  Created by User on 11.01.2025.
//

import SwiftUI

struct OverviewTab: View {
    @Binding var character: any BaseCharacter
    @ObservedObject var store: CharacterStore
    @Binding var isEditMode: Bool
    @State private var showingUnifiedStatusPopup = false
    @State private var showingChangeHistoryPopup = false
    @State private var tempSolars: Int = 0
    @State private var originalSolars: Int = 0
    @State private var originalSnapshot: CharacterSnapshot? = nil
    
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
        GeometryReader { geometry in
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                // Character Header - Full width background
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
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(.systemGray6))
                
                // Spacing between sections
                Rectangle().fill(Color.clear).frame(height: 20)
                
                // Character Goals and Description - Full width background
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
                                TextEditor(text: shortTermGoalBinding)
                                    .frame(minHeight: 60)
                                    .background(Color(.systemGray6))
                                    .cornerRadius(8)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(Color(.systemGray4), lineWidth: 1)
                                    )
                                    .overlay(
                                        Group {
                                            if imperium.shortTermGoal.isEmpty {
                                                Text("Short-term Goal")
                                                    .foregroundColor(.secondary)
                                                    .allowsHitTesting(false)
                                                    .padding(.horizontal, 8)
                                                    .padding(.vertical, 8)
                                            }
                                        }, alignment: .topLeading
                                    )
                            }
                            
                            let longTermGoalBinding = Binding<String>(
                                get: { imperium.longTermGoal },
                                set: { imperium.longTermGoal = $0 }
                            )
                            VStack(alignment: .leading) {
                                Text("Long-term Goal")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                TextEditor(text: longTermGoalBinding)
                                    .frame(minHeight: 60)
                                    .background(Color(.systemGray6))
                                    .cornerRadius(8)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(Color(.systemGray4), lineWidth: 1)
                                    )
                                    .overlay(
                                        Group {
                                            if imperium.longTermGoal.isEmpty {
                                                Text("Long-term Goal")
                                                    .foregroundColor(.secondary)
                                                    .allowsHitTesting(false)
                                                    .padding(.horizontal, 8)
                                                    .padding(.vertical, 8)
                                            }
                                        }, alignment: .topLeading
                                    )
                            }
                            
                            let descriptionBinding = Binding<String>(
                                get: { imperium.characterDescription },
                                set: { imperium.characterDescription = $0 }
                            )
                            VStack(alignment: .leading) {
                                Text("Description")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                TextEditor(text: descriptionBinding)
                                    .frame(minHeight: 80)
                                    .background(Color(.systemGray6))
                                    .cornerRadius(8)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(Color(.systemGray4), lineWidth: 1)
                                    )
                                    .overlay(
                                        Group {
                                            if imperium.characterDescription.isEmpty {
                                                Text("Character Description")
                                                    .foregroundColor(.secondary)
                                                    .allowsHitTesting(false)
                                                    .padding(.horizontal, 8)
                                                    .padding(.vertical, 8)
                                            }
                                        }, alignment: .topLeading
                                    )
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
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                    }
                
                // Spacing between sections
                Rectangle().fill(Color.clear).frame(height: 20)
                
                // Character Details - Full width background
                if let imperium = imperiumCharacter {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Background Details")
                        .font(.headline)
                        
                        if !imperium.background.isEmpty {
                            DetailRow(title: "Background", value: imperium.background)
                        }
                        
                        if isEditMode {
                            HStack {
                                Text("Wealth (Solars)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Spacer()
                                TextField("Solars", value: $tempSolars, format: .number)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .frame(width: max(80, geometry.size.width * 0.15))
                                    .keyboardType(.numberPad)
                                    .onAppear {
                                        if let imperium = imperiumCharacter {
                                            tempSolars = imperium.solars
                                            originalSolars = imperium.solars
                                            originalSnapshot = store.createSnapshot(of: imperium)
                                        }
                                    }
                                    .onSubmit {
                                        saveSolarsChanges()
                                    }
                                    .onChange(of: isEditMode) { newValue in
                                        if !newValue {
                                            saveSolarsChanges()
                                        } else if let imperium = imperiumCharacter {
                                            // Entering edit mode - capture snapshot
                                            tempSolars = imperium.solars
                                            originalSolars = imperium.solars
                                            originalSnapshot = store.createSnapshot(of: imperium)
                                        }
                                    }
                                    .onDisappear {
                                        saveSolarsChanges()
                                    }
                            }
                        } else if imperium.solars > 0 {
                            DetailRow(title: "Wealth", value: "\(imperium.solars) Solars")
                        }
                        
                        if imperium.background.isEmpty && imperium.solars == 0 {
                            Text("No background details provided")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .italic()
                        }
                        }
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                    }
                
                // Spacing between sections
                Rectangle().fill(Color.clear).frame(height: 20)
                
                // Experience Block - Full width background
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
                                        .frame(width: max(80, geometry.size.width * 0.15))
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
                                        .frame(width: max(80, geometry.size.width * 0.15))
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
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(.systemGray6))
                }
                
                // Spacing between sections
                Rectangle().fill(Color.clear).frame(height: 20)
                
                // Notes Section - Full width background
                if let imperium = imperiumCharacter {
                    VStack(alignment: .leading, spacing: 12) {
                    Text("Notes")
                        .font(.headline)
                        
                        if isEditMode {
                            let notesBinding = Binding<String>(
                                get: { imperium.notes },
                                set: { imperium.notes = $0 }
                            )
                            TextEditor(text: notesBinding)
                                .frame(minHeight: 80)
                                .background(Color(.systemGray6))
                                .cornerRadius(8)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color(.systemGray4), lineWidth: 1)
                                )
                                .overlay(
                                    Group {
                                        if imperium.notes.isEmpty {
                                            Text("Additional notes about your character")
                                                .foregroundColor(.secondary)
                                                .allowsHitTesting(false)
                                                .padding(.horizontal, 8)
                                                .padding(.vertical, 8)
                                        }
                                    }, alignment: .topLeading
                                )
                        } else {
                            if !imperium.notes.isEmpty {
                                Text(imperium.notes)
                                    .font(.body)
                                    .padding(.top, 4)
                            } else {
                                Text("No notes provided")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .italic()
                            }
                        }
                        }
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                    }
            }
            .padding(.bottom, 80) // Extra space for floating buttons
        }
        }
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
    }
    
    private func saveSolarsChanges() {
        guard let imperium = imperiumCharacter,
              let snapshot = originalSnapshot,
              tempSolars != originalSolars else { return }
        
        imperium.solars = tempSolars
        store.saveCharacterWithAutoChangeTracking(imperium, originalSnapshot: snapshot)
        originalSolars = tempSolars
        originalSnapshot = store.createSnapshot(of: imperium) // Update snapshot for potential future changes
    }
}