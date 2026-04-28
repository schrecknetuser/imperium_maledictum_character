# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

iOS app for creating and managing characters in the Warhammer 40K Imperium Maledictum tabletop RPG. Built with SwiftUI + SwiftData, targeting iOS 17+.

## Build & Run

Open `ImperiumMaledictumCharacter/ImperiumMaledictumCharacter.xcodeproj` in Xcode 15+. No external dependencies or package managers — build and run directly. No test targets exist.

## Architecture

**Entry point**: `ImperiumMaledictumCharacterApp.swift` sets up the SwiftData `ModelContainer` with `ImperiumCharacter` as the sole model, then presents `ContentView`.

**Data flow**: `CharacterStore` (`@Observable`, `@MainActor`) owns the SwiftData `ModelContext` and provides all CRUD, filtering, and change-tracking operations. Views read from the store and call its methods to mutate state.

### Key layers

| Layer | Location | Purpose |
|-------|----------|---------|
| Models | `Characters/` | `ImperiumCharacter` (@Model) + supporting Codable structs (skills, weapons, equipment, etc.) |
| Store | `Characters/CharacterStore.swift` | Persistence, queries, change tracking |
| Creation | `Creation/CharacterCreationWizard.swift` | 6-stage guided wizard (BasicInfo → Characteristics → Origin → Faction → Role → Completion) |
| Display | `Display/` | Tab-based character detail views + popup overlays |
| Root | `ContentView.swift` | Character list grouped by campaign with archive/delete |

### Data model patterns

`ImperiumCharacter` uses a **hybrid storage approach**: primitive properties for simple values (name, wound counts, individual characteristic integers) alongside JSON-serialized strings for complex collections (skills advances, specializations, equipment lists). The JSON properties have names ending in `Data` (e.g., `skillsAdvancesData`, `skillSpecializationsData`).

Game data definitions (factions, roles, homeworlds, weapon templates, talent definitions, equipment catalogs) are defined as static constants in their respective model files — not loaded from external data files.

### Change tracking

1. When the user taps "Edit" on a character, `CharacterStore.createSnapshot(of:)` captures current state into a `CharacterSnapshot`.
2. On "Done", `saveCharacterWithAutoChangeTracking()` compares against the snapshot and appends a `ChangeLogEntry` to the character's `changeLog` array.
3. Each entry records a summary, timestamp, and session number.

### Character creation

`CharacterCreationWizard.swift` implements a multi-stage wizard where each stage validates before allowing progression. Stages apply bonuses/equipment to the character incrementally. The character is persisted in SwiftData during creation (marked via `isInCreation` flag) so progress survives app restarts.

## Code style

- SwiftUI views conform to `View` with UI in `body`
- 4-space indentation
- `@State private var` for local view state
- `@Bindable` for SwiftData model bindings in views
- No Combine — uses `@Observable` macro pattern
