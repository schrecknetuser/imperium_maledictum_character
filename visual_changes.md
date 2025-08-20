## Visual Changes Summary

### BEFORE: Multiple Floating Buttons (OverviewTab only)
```
┌─────────────────────────────────────┐
│                          ┌─────┐    │
│    Character Overview    │  🔺 │◄───┼─ Conditions Button (Orange)
│                          └─────┘    │
│                          ┌─────┐    │
│                          │  🩹 │◄───┼─ Injuries Button (Red)
│                          └─────┘    │
│                          ┌─────┐    │
│                          │  💖 │◄───┼─ Status Button (Blue)
│                          └─────┘    │
└─────────────────────────────────────┘
```

### AFTER: Single Floating Button (All Tabs)
```
┌─────────────────────────────────────┐
│                                     │
│    Any Tab View                     │
│    (Overview, Stats, Reputation,    │
│     Talents, Equipment, Psychic)    │
│                                     │
│                          ┌─────┐    │
│                          │  💖 │◄───┼─ Unified Status Button (Blue)
│                          └─────┘    │
└─────────────────────────────────────┘
```

### Unified Popup Structure
```
┌─────────────────────────────────────────────────────────────┐
│ Character Status                                      Done  │
├─────────────────────────────────────────────────────────────┤
│ ┌─────────┐ ┌─────────┐ ┌─────────┐                         │
│ │ Status  │ │Injuries │ │Condition│                         │
│ │   💖    │ │   🩹    │ │   🔺    │                         │
│ └─────────┘ └─────────┘ └─────────┘                         │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  [Currently selected tab content shows here]                │
│                                                             │
│  • Status Tab:                                             │
│    - Wounds (with +/- buttons)                             │
│    - Corruption (with +/- buttons)                         │
│    - Critical Wounds (auto-calculated)                     │
│    - Fate Points management                                 │
│                                                             │
│  • Injuries Tab:                                           │
│    - Head/Arm/Body/Leg injury tabs                         │
│    - Add/remove specific injuries                          │
│    - Full injury management                                 │
│                                                             │
│  • Conditions Tab:                                         │
│    - Active conditions list                                 │
│    - Add new conditions                                     │
│    - Remove existing conditions                             │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### Button Placement Across All Tabs
```
┌─ Overview Tab ─┐  ┌─ Stats Tab ──┐  ┌─ Reputation ─┐
│      💖        │  │      💖      │  │      💖      │
└────────────────┘  └──────────────┘  └──────────────┘

┌─ Talents Tab ──┐  ┌─ Equipment ──┐  ┌─ Psychic ────┐
│      💖        │  │      💖      │  │      💖      │
└────────────────┘  └──────────────┘  └──────────────┘
```

### Key Improvements
1. **Reduced Clutter**: 3 buttons → 1 button on overview
2. **Universal Access**: Status button now on ALL 6 tabs
3. **Organized Content**: All related features in one unified interface
4. **Better UX**: Clear navigation between Status/Injuries/Conditions
5. **Consistent Design**: Same button style and positioning everywhere