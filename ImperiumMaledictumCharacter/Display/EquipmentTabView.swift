//
//  EquipmentTabView.swift
//  ImperiumMaledictumCharacter
//
//  Created by User on 11.01.2025.
//

import SwiftUI

struct EquipmentTab: View {
    let character: any BaseCharacter
    @ObservedObject var store: CharacterStore
    @Binding var isEditMode: Bool
    @State private var showingAddEquipmentSheet = false
    @State private var showingAddWeaponSheet = false
    @State private var showingWeaponSelectionPopup = false
    @State private var showingEquipmentSelectionPopup = false
    @State private var editingEquipmentState: EditingEquipmentState = .none
    @State private var editingWeaponState: EditingWeaponState = .none
    @State private var showingEquipmentDeleteConfirmation = false
    @State private var showingWeaponDeleteConfirmation = false
    @State private var equipmentToDelete: Equipment?
    @State private var weaponToDelete: Weapon?
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
    
    // Computed properties for sheet presentation
    private var showingEditEquipmentSheet: Binding<Bool> {
        Binding(
            get: { 
                if case .editing = editingEquipmentState { return true }
                return false
            },
            set: { isPresented in
                if !isPresented {
                    editingEquipmentState = .none
                }
            }
        )
    }
    
    private var showingEditWeaponSheet: Binding<Bool> {
        Binding(
            get: { 
                if case .editing = editingWeaponState { return true }
                return false
            },
            set: { isPresented in
                if !isPresented {
                    editingWeaponState = .none
                }
            }
        )
    }
    
    var body: some View {
        NavigationView {
            List {
                if let imperium = imperiumCharacter {
                    Section("Equipment") {
                        let groupedEquipment = Dictionary(grouping: imperium.equipmentList) { equipment in
                            EquipmentTemplateDefinitions.getCategoryForEquipment(equipment.name)
                        }
                        
                        ForEach(EquipmentCategories.all + ["Other"], id: \.self) { category in
                            if let equipmentInCategory = groupedEquipment[category], !equipmentInCategory.isEmpty {
                                // Category header
                                HStack {
                                    Text(category)
                                        .font(.headline)
                                        .foregroundColor(.primary)
                                    Spacer()
                                    Text("(\(equipmentInCategory.count))")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                .padding(.vertical, 4)
                                
                                ForEach(Array(equipmentInCategory.enumerated()), id: \.offset) { index, equipment in
                                    HStack {
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text(equipment.name)
                                                .font(.body)
                                            
                                            if !equipment.equipmentDescription.isEmpty {
                                                Text(equipment.equipmentDescription)
                                                    .font(.caption)
                                                    .foregroundColor(.secondary)
                                                    .lineLimit(3)
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
                                                    equipmentToDelete = equipment
                                                    showingEquipmentDeleteConfirmation = true
                                                }) {
                                                    Image(systemName: "minus.circle.fill")
                                                        .foregroundColor(.red)
                                                }
                                                .buttonStyle(PlainButtonStyle())
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        
                        if isEditMode {
                            Button(action: {
                                showingEquipmentSelectionPopup = true
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
                        let groupedWeapons = Dictionary(grouping: imperium.weaponList) { $0.category }
                        
                        ForEach(WeaponCategories.all, id: \.self) { category in
                            if let weaponsInCategory = groupedWeapons[category], !weaponsInCategory.isEmpty {
                                // Category header
                                HStack {
                                    Text(category)
                                        .font(.headline)
                                        .foregroundColor(.primary)
                                    Spacer()
                                    Text("(\(weaponsInCategory.count))")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                .padding(.vertical, 4)
                                
                                ForEach(Array(weaponsInCategory.enumerated()), id: \.offset) { index, weapon in
                                    HStack {
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text(weapon.name)
                                                .font(.body)
                                            
                                            if !weapon.weaponDescription.isEmpty {
                                                Text(weapon.weaponDescription)
                                                    .font(.caption)
                                                    .foregroundColor(.secondary)
                                                    .lineLimit(3)
                                            }
                                            
                                            // Show weapon stats based on category
                                            if weapon.category == WeaponCategories.melee {
                                                Text("Damage: \(weapon.damage)")
                                                    .font(.caption)
                                                    .foregroundColor(.secondary)
                                            } else {
                                                Text("Damage: \(weapon.damage), Range: \(weapon.range), Magazine: \(weapon.magazine)")
                                                    .font(.caption)
                                                    .foregroundColor(.secondary)
                                            }
                                            
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
                                                    weaponToDelete = weapon
                                                    showingWeaponDeleteConfirmation = true
                                                }) {
                                                    Image(systemName: "minus.circle.fill")
                                                        .foregroundColor(.red)
                                                }
                                                .buttonStyle(PlainButtonStyle())
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        
                        if isEditMode {
                            Button(action: {
                                showingWeaponSelectionPopup = true
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
                
                // Bottom spacing for floating buttons
                Section {
                    Color.clear.frame(height: 76)
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                }
            }
            .navigationTitle("Equipment")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                // Migrate old string-based data to new object-based system
                imperiumCharacter?.migrateEquipmentAndWeapons()
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
        .sheet(isPresented: $showingAddEquipmentSheet) {
            if let imperium = imperiumCharacter {
                ComprehensiveEquipmentSheet(character: imperium, store: store, isWeapon: false, isEditMode: isEditMode)
            }
        }
        .sheet(isPresented: $showingAddWeaponSheet) {
            if let imperium = imperiumCharacter {
                ComprehensiveEquipmentSheet(character: imperium, store: store, isWeapon: true, isEditMode: isEditMode)
            }
        }
        .sheet(isPresented: $showingWeaponSelectionPopup) {
            if let imperium = imperiumCharacter {
                WeaponSelectionPopupView(character: imperium, store: store, showingCustomWeaponSheet: $showingAddWeaponSheet, isEditMode: isEditMode)
            }
        }
        .sheet(isPresented: $showingEquipmentSelectionPopup) {
            if let imperium = imperiumCharacter {
                EquipmentSelectionPopupView(character: imperium, store: store, showingCustomEquipmentSheet: $showingAddEquipmentSheet, isEditMode: isEditMode)
            }
        }
        .sheet(isPresented: showingEditEquipmentSheet) {
            if let imperium = imperiumCharacter, case .editing(let equipment) = editingEquipmentState {
                ComprehensiveEquipmentSheet(character: imperium, store: store, isWeapon: false, editingEquipment: equipment, isEditMode: isEditMode)
            }
        }
        .sheet(isPresented: showingEditWeaponSheet) {
            if let imperium = imperiumCharacter, case .editing(let weapon) = editingWeaponState {
                ComprehensiveEquipmentSheet(character: imperium, store: store, isWeapon: true, editingWeapon: weapon, isEditMode: isEditMode)
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
        .alert("Delete Equipment", isPresented: $showingEquipmentDeleteConfirmation) {
            Button("Cancel", role: .cancel) {
                equipmentToDelete = nil
            }
            Button("Delete", role: .destructive) {
                if let equipment = equipmentToDelete {
                    removeEquipment(equipment)
                }
                equipmentToDelete = nil
            }
        } message: {
            if let equipment = equipmentToDelete {
                Text("Are you sure you want to delete '\(equipment.name)'? This action cannot be undone.")
            }
        }
        .alert("Delete Weapon", isPresented: $showingWeaponDeleteConfirmation) {
            Button("Cancel", role: .cancel) {
                weaponToDelete = nil
            }
            Button("Delete", role: .destructive) {
                if let weapon = weaponToDelete {
                    removeWeapon(weapon)
                }
                weaponToDelete = nil
            }
        } message: {
            if let weapon = weaponToDelete {
                Text("Are you sure you want to delete '\(weapon.name)'? This action cannot be undone.")
            }
        }
    }
    
    private func buildEquipmentDetails(_ equipment: Equipment) -> String {
        var details: [String] = []
        
        // Equipment should not show weapon traits - only qualities and flaws
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
        // Clear any other editing state first
        editingWeaponState = .none
        
        // Set the editing equipment atomically
        editingEquipmentState = .editing(equipment)
    }
    
    private func editWeapon(_ weapon: Weapon) {
        // Clear any other editing state first
        editingEquipmentState = .none
        
        // Set the editing weapon atomically
        editingWeaponState = .editing(weapon)
    }
    
    private func removeEquipment(_ equipment: Equipment) {
        guard let imperium = imperiumCharacter else { return }
        
        var equipmentList = imperium.equipmentList
        // Remove the specific equipment instance using ID
        if let index = equipmentList.firstIndex(where: { $0.id == equipment.id }) {
            equipmentList.remove(at: index)
        }
        imperium.equipmentList = equipmentList
        
        // Only use immediate change tracking if not in edit mode
        // When in edit mode, let the main "Done" button handle change tracking
        if !isEditMode {
            let originalSnapshot = store.createSnapshot(of: imperium)
            store.saveCharacterWithAutoChangeTracking(imperium, originalSnapshot: originalSnapshot)
        } else {
            store.saveChanges() // Just save to SwiftData without change tracking
        }
    }
    
    private func removeWeapon(_ weapon: Weapon) {
        guard let imperium = imperiumCharacter else { return }
        
        var weaponList = imperium.weaponList
        // Remove the specific weapon instance using ID
        if let index = weaponList.firstIndex(where: { $0.id == weapon.id }) {
            weaponList.remove(at: index)
        }
        imperium.weaponList = weaponList
        
        // Only use immediate change tracking if not in edit mode
        // When in edit mode, let the main "Done" button handle change tracking
        if !isEditMode {
            let originalSnapshot = store.createSnapshot(of: imperium)
            store.saveCharacterWithAutoChangeTracking(imperium, originalSnapshot: originalSnapshot)
        } else {
            store.saveChanges() // Just save to SwiftData without change tracking
        }
    }
}

struct ComprehensiveEquipmentSheet: View {
    let character: ImperiumCharacter
    @ObservedObject var store: CharacterStore
    let isWeapon: Bool
    let editingEquipment: Equipment?
    let editingWeapon: Weapon?
    let isEditMode: Bool
    @Environment(\.dismiss) private var dismiss
    
    // Note: @State variables must be initialized in the main initializer below
    
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
    @State private var category = WeaponCategories.ranged
    @State private var specialization = WeaponSpecializations.none
    @State private var damage = ""
    @State private var range = WeaponRanges.short
    @State private var magazine = 0
    @State private var selectedWeaponTraits: Set<String> = []
    @State private var selectedModifications: Set<String> = []
    
    // UI state
    @State private var showingTraitPicker = false
    @State private var showingWeaponTraitPicker = false
    
    init(character: ImperiumCharacter, store: CharacterStore, isWeapon: Bool, editingEquipment: Equipment? = nil, editingWeapon: Weapon? = nil, isEditMode: Bool = false) {
        self.character = character
        self.store = store
        self.isWeapon = isWeapon
        self.editingEquipment = editingEquipment
        self.editingWeapon = editingWeapon
        self.isEditMode = isEditMode
        
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
            _category = State(initialValue: WeaponCategories.ranged)
            _specialization = State(initialValue: WeaponSpecializations.none)
            _damage = State(initialValue: "")
            _range = State(initialValue: WeaponRanges.short)
            _magazine = State(initialValue: 0)
            _selectedWeaponTraits = State(initialValue: [])
            _selectedModifications = State(initialValue: [])
        } else if let weapon = editingWeapon, isWeapon {
            // Editing existing weapon
            _itemName = State(initialValue: weapon.name.isEmpty ? "Unnamed Weapon" : weapon.name)
            _itemDescription = State(initialValue: weapon.weaponDescription)
            _category = State(initialValue: weapon.category.isEmpty ? WeaponCategories.ranged : weapon.category)
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
            _category = State(initialValue: WeaponCategories.ranged)
            _specialization = State(initialValue: WeaponSpecializations.none)
            _damage = State(initialValue: "")
            _range = State(initialValue: WeaponRanges.short)
            _magazine = State(initialValue: 0)
            _selectedWeaponTraits = State(initialValue: [])
            _selectedModifications = State(initialValue: [])
        }
        
        // Initialize UI state
        _showingTraitPicker = State(initialValue: false)
        _showingWeaponTraitPicker = State(initialValue: false)
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
                        Picker("Category", selection: $category) {
                            ForEach(WeaponCategories.all, id: \.self) { cat in
                                Text(cat).tag(cat)
                            }
                        }
                        
                        Picker("Specialization", selection: $specialization) {
                            ForEach(WeaponSpecializations.all, id: \.self) { spec in
                                Text(spec).tag(spec)
                            }
                        }
                        
                        TextField("Damage", text: $damage)
                        
                        if category != WeaponCategories.melee {
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
                weaponDescription: itemDescription,
                category: category,
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
                // Remove only the specific weapon instance being edited using ID
                if let index = weaponList.firstIndex(where: { $0.id == editingWeapon.id }) {
                    weaponList.remove(at: index)
                }
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
            
            // Set equipment properties (equipment should not have weapon traits)
            equipment.traits = []
            equipment.qualities = Array(selectedQualities)
            equipment.flaws = Array(selectedFlaws)
            
            var equipmentList = character.equipmentList
            
            if let editingEquipment = editingEquipment {
                // Remove only the specific equipment instance being edited using ID
                if let index = equipmentList.firstIndex(where: { $0.id == editingEquipment.id }) {
                    equipmentList.remove(at: index)
                }
            }
            
            equipmentList.append(equipment)
            character.equipmentList = equipmentList
        }
        
        // Only use immediate change tracking if not in edit mode
        // When in edit mode, let the main "Done" button handle change tracking
        if !isEditMode {
            let originalSnapshot = store.createSnapshot(of: character)
            store.saveCharacterWithAutoChangeTracking(character, originalSnapshot: originalSnapshot)
        } else {
            store.saveChanges() // Just save to SwiftData without change tracking
        }
        dismiss()
    }
}

// MARK: - Weapon Selection Popup
struct WeaponSelectionPopupView: View {
    let character: ImperiumCharacter
    @ObservedObject var store: CharacterStore
    @Binding var showingCustomWeaponSheet: Bool
    let isEditMode: Bool
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedCategory: String = WeaponCategories.ranged
    @State private var selectionMode: SelectionMode = .category
    
    enum SelectionMode {
        case category
        case weapon
    }
    
    var body: some View {
        NavigationStack {
            Group {
                if selectionMode == .category {
                    categorySelectionView
                } else {
                    weaponSelectionView
                }
            }
            .navigationTitle("Add Weapon")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Add Custom") {
                        dismiss()
                        showingCustomWeaponSheet = true
                    }
                }
            }
        }
    }
    
    private var categorySelectionView: some View {
        List {
            Section {
                ForEach(WeaponCategories.all, id: \.self) { category in
                    let weaponsInCategory = WeaponTemplateDefinitions.getWeaponsByCategory(category)
                    
                    Button(action: {
                        selectedCategory = category
                        selectionMode = .weapon
                    }) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(category)
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                
                                Text("\(weaponsInCategory.count) weapons available")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .foregroundColor(.secondary)
                        }
                        .padding(.vertical, 8)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            } header: {
                Text("Select Weapon Category")
            } footer: {
                Text("Choose a category to see available weapon templates.")
            }
        }
    }
    
    private var weaponSelectionView: some View {
        List {
            Section {
                Button(action: {
                    selectionMode = .category
                }) {
                    HStack {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.blue)
                        Text("Back to Categories")
                            .foregroundColor(.blue)
                        Spacer()
                    }
                }
                .buttonStyle(PlainButtonStyle())
            }
            
            Section {
                let weaponsInCategory = WeaponTemplateDefinitions.getWeaponsByCategory(selectedCategory)
                
                ForEach(Array(weaponsInCategory.enumerated()), id: \.offset) { index, template in
                    Button(action: {
                        addWeaponFromTemplate(template)
                    }) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(template.name)
                                    .font(.body)
                                    .foregroundColor(.primary)
                                
                                HStack {
                                    Text("Damage: \(template.damage)")
                                    
                                    if template.category != WeaponCategories.melee {
                                        Text("Range: \(template.range)")
                                        Text("Mag: \(template.magazine)")
                                    }
                                }
                                .font(.caption)
                                .foregroundColor(.secondary)
                                
                                if !template.traits.isEmpty {
                                    Text("Traits: \(template.traits.joined(separator: ", "))")
                                        .font(.caption2)
                                        .foregroundColor(.secondary)
                                        .lineLimit(2)
                                }
                                
                                HStack {
                                    Text("Cost: \(template.cost)")
                                    Text("Encumbrance: \(template.encumbrance)")
                                    Text(template.availability)
                                }
                                .font(.caption2)
                                .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            Image(systemName: "plus.circle.fill")
                                .foregroundColor(.blue)
                        }
                        .padding(.vertical, 4)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            } header: {
                Text("\(selectedCategory) Weapons")
            } footer: {
                Text("Tap a weapon to add it to your character, or use 'Add Custom' for a custom weapon.")
            }
        }
    }
    
    private func addWeaponFromTemplate(_ template: WeaponTemplate) {
        let weapon = template.createWeapon()
        
        var weaponList = character.weaponList
        weaponList.append(weapon)
        character.weaponList = weaponList
        
        // Only use immediate change tracking if not in edit mode
        // When in edit mode, let the main "Done" button handle change tracking
        if !isEditMode {
            let originalSnapshot = store.createSnapshot(of: character)
            store.saveCharacterWithAutoChangeTracking(character, originalSnapshot: originalSnapshot)
        } else {
            store.saveChanges() // Just save to SwiftData without change tracking
        }
        
        dismiss()
    }
}

// MARK: - Equipment Selection Popup
struct EquipmentSelectionPopupView: View {
    let character: ImperiumCharacter
    @ObservedObject var store: CharacterStore
    @Binding var showingCustomEquipmentSheet: Bool
    let isEditMode: Bool
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedCategory: String = EquipmentCategories.clothingPersonalGear
    @State private var selectionMode: SelectionMode = .category
    
    enum SelectionMode {
        case category
        case equipment
    }
    
    var body: some View {
        NavigationStack {
            Group {
                if selectionMode == .category {
                    categorySelectionView
                } else {
                    equipmentSelectionView
                }
            }
            .navigationTitle("Add Equipment")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Add Custom") {
                        dismiss()
                        showingCustomEquipmentSheet = true
                    }
                }
            }
        }
    }
    
    private var categorySelectionView: some View {
        List {
            Section {
                ForEach(EquipmentCategories.all, id: \.self) { category in
                    let equipmentInCategory = EquipmentTemplateDefinitions.getEquipmentByCategory(category)
                    
                    Button(action: {
                        selectedCategory = category
                        selectionMode = .equipment
                    }) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(category)
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                
                                Text("\(equipmentInCategory.count) items available")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .foregroundColor(.secondary)
                        }
                        .padding(.vertical, 8)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            } header: {
                Text("Select Equipment Category")
            } footer: {
                Text("Choose a category to see available equipment templates.")
            }
        }
    }
    
    private var equipmentSelectionView: some View {
        List {
            Section {
                Button(action: {
                    selectionMode = .category
                }) {
                    HStack {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.blue)
                        Text("Back to Categories")
                            .foregroundColor(.blue)
                        Spacer()
                    }
                }
                .buttonStyle(PlainButtonStyle())
            }
            
            Section {
                let equipmentInCategory = EquipmentTemplateDefinitions.getEquipmentByCategory(selectedCategory)
                
                ForEach(Array(equipmentInCategory.enumerated()), id: \.offset) { index, template in
                    Button(action: {
                        addEquipmentFromTemplate(template)
                    }) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(template.name)
                                    .font(.body)
                                    .foregroundColor(.primary)
                                
                                if !template.description.isEmpty {
                                    Text(template.description)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                        .lineLimit(3)
                                }
                                
                                if !template.traits.isEmpty {
                                    Text("Traits: \(template.traits.map { $0.displayName }.joined(separator: ", "))")
                                        .font(.caption2)
                                        .foregroundColor(.secondary)
                                        .lineLimit(2)
                                }
                                
                                HStack {
                                    Text("Cost: \(template.cost)")
                                    Text("Encumbrance: \(template.encumbrance)")
                                    Text(template.availability)
                                }
                                .font(.caption2)
                                .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            Image(systemName: "plus.circle.fill")
                                .foregroundColor(.blue)
                        }
                        .padding(.vertical, 4)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            } header: {
                Text("\(selectedCategory)")
            } footer: {
                Text("Tap equipment to add it to your character, or use 'Add Custom' for custom equipment.")
            }
        }
    }
    
    private func addEquipmentFromTemplate(_ template: EquipmentTemplate) {
        let equipment = template.createEquipment()
        
        var equipmentList = character.equipmentList
        equipmentList.append(equipment)
        character.equipmentList = equipmentList
        
        // Only use immediate change tracking if not in edit mode
        // When in edit mode, let the main "Done" button handle change tracking
        if !isEditMode {
            let originalSnapshot = store.createSnapshot(of: character)
            store.saveCharacterWithAutoChangeTracking(character, originalSnapshot: originalSnapshot)
        } else {
            store.saveChanges() // Just save to SwiftData without change tracking
        }
        
        dismiss()
    }
}