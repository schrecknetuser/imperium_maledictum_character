# Specialization Data Structure Fix

## Problem Statement

The original specialization system had a critical flaw: specializations for different skills could have identical names, making them indistinguishable in the data structure.

**Examples of duplicate specialization names:**
- "Human" appears in both **Intuition** and **Medicae** skills
- "Forbidden" appears in **Linguistics**, **Lore**, and **Medicae** skills

### Impact of the Problem

When a character had both "Human (Intuition)" and "Human (Medicae)" specializations:
```swift
// Old problematic data structure
var specializationAdvances: [String: Int] = [:]
specializationAdvances["Human"] = 2  // For Intuition? 
specializationAdvances["Human"] = 3  // Overwrites the previous! Now for Medicae?
// Result: Only one "Human" specialization survives, losing data
```

## Solution

Changed the data structure to use **composite keys** that include both the specialization name and the skill name:

### New Data Format
```swift
// New composite key format
"Human (Intuition)" -> 2 advances
"Human (Medicae)" -> 3 advances
"Forbidden (Lore)" -> 1 advance
"Forbidden (Medicae)" -> 2 advances
```

### Key Components

1. **Utility Functions** (in `ImperiumCharacter.swift`):
   ```swift
   static func makeSpecializationKey(specialization: String, skill: String) -> String
   static func parseSpecializationKey(_ key: String) -> (specialization: String, skill: String?)
   ```

2. **Convenience Methods**:
   ```swift
   func getSpecializationAdvances(specialization: String, skill: String) -> Int
   func setSpecializationAdvances(specialization: String, skill: String, advances: Int)
   ```

### Benefits

✅ **Preserves All Data**: No more lost specializations due to name conflicts
✅ **Clear Context**: UI can show "Human (Intuition)" vs "Human (Medicae)"
✅ **Minimal Changes**: Same underlying `[String: Int]` structure
✅ **Backward Compatible**: Handles legacy data gracefully
✅ **Type Safe**: Strong typing prevents skill/specialization mismatches

### Implementation Details

The solution maintains the existing `[String: Int]` dictionary structure but changes the key format:

- **Internal Storage**: `"Human (Intuition)": 2`
- **UI Display**: Shows clean context like "Human (Intuition): 2 advances"
- **Legacy Support**: Keys without "(Skill)" format are handled via fallback lookup

### Files Modified

1. **`ImperiumCharacter.swift`**: Added utility functions and convenience methods
2. **`CharacteristicsTabView.swift`**: Updated UI to use composite keys
3. **`CharacterCreationWizard.swift`**: Updated character creation to use composite keys

## Testing

Created comprehensive tests demonstrating:
- Composite key generation and parsing
- Proper separation of duplicate specialization names  
- Backward compatibility with legacy data
- UI display showing clear context

The fix ensures that "Human (Intuition)" and "Human (Medicae)" specializations can coexist and be managed independently.