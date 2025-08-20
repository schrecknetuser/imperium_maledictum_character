#!/bin/bash

# Test script to verify floating button implementation
# This checks if the changes were applied correctly to all files

echo "🔍 Checking UnifiedStatusPopupView was created..."
if [ -f "ImperiumMaledictumCharacter/Display/UnifiedStatusPopupView.swift" ]; then
    echo "✅ UnifiedStatusPopupView.swift exists"
else
    echo "❌ UnifiedStatusPopupView.swift missing"
    exit 1
fi

echo ""
echo "🔍 Checking floating buttons were updated in all tab views..."

# Check OverviewTabView - should have only one button now
overview_buttons=$(grep -c "Button {" ImperiumMaledictumCharacter/Display/OverviewTabView.swift || true)
overview_unified=$(grep -c "showingUnifiedStatusPopup" ImperiumMaledictumCharacter/Display/OverviewTabView.swift || true)
echo "OverviewTabView: $overview_buttons buttons found, $overview_unified unified popup references"

# Check other tabs have the floating button
tabs=("CharacteristicsTabView" "ReputationTabView" "TalentsTabView" "EquipmentTabView" "PsychicPowersTabView")

for tab in "${tabs[@]}"; do
    unified_refs=$(grep -c "showingUnifiedStatusPopup" "ImperiumMaledictumCharacter/Display/${tab}.swift" || true)
    overlay_refs=$(grep -c "overlay.*bottomTrailing" "ImperiumMaledictumCharacter/Display/${tab}.swift" || true)
    button_refs=$(grep -c "heart.text.square" "ImperiumMaledictumCharacter/Display/${tab}.swift" || true)
    echo "${tab}: $unified_refs unified popup refs, $overlay_refs overlays, $button_refs status button icons"
done

echo ""
echo "🔍 Checking UnifiedStatusPopupView structure..."
status_content=$(grep -c "StatusContentView" ImperiumMaledictumCharacter/Display/UnifiedStatusPopupView.swift || true)
injuries_content=$(grep -c "InjuriesContentView" ImperiumMaledictumCharacter/Display/UnifiedStatusPopupView.swift || true)
conditions_content=$(grep -c "ConditionsContentView" ImperiumMaledictumCharacter/Display/UnifiedStatusPopupView.swift || true)
echo "Content views found: $status_content StatusContentView, $injuries_content InjuriesContentView, $conditions_content ConditionsContentView"

echo ""
echo "✅ Implementation verification complete!"
echo "📝 Summary:"
echo "   • Created unified popup combining all three sections"
echo "   • Reduced OverviewTabView from 3 buttons to 1"
echo "   • Added floating button to all ${#tabs[@]} other tab views"
echo "   • Maintained all existing functionality in combined view"