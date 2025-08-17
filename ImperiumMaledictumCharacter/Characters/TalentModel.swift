//
//  TalentModel.swift
//  ImperiumMaledictumCharacter
//
//  Created by User on 11.01.2025.
//

import Foundation
import SwiftData

@Model
class Talent {
    var name: String
    var talentDescription: String
    
    init(name: String, talentDescription: String = "") {
        self.name = name
        self.talentDescription = talentDescription
    }
}

// MARK: - Talent Definitions
struct TalentDefinitions {
    static let talents: [String: String] = [
        "Acute Sense": "Enhanced sensory perception",
        "Adrenaline Acceleration": "Combat reflexes enhanced by stress",
        "Agile Attacks": "Quick strikes in combat",
        "Air of Authority": "Natural leadership presence",
        "Ambidextrous": "Equal skill with both hands",
        "Applied Anatomy": "Knowledge of biological weak points",
        "Artistic": "Creative and aesthetic talents",
        "Attentive Assistant": "Skilled at supporting others",
        "Blank": "Psychic null - immunity to warp effects",
        "Bone Breaker": "Expertise in inflicting grievous wounds",
        "Briber": "Skilled at corrupting officials",
        "Bulwark": "Defensive combat specialist",
        "Burglar": "Expert at breaking and entering",
        "Chirurgeon": "Advanced medical knowledge",
        "Close Quarters Discipline": "Training in confined combat",
        "Combat Master": "Superior fighting techniques",
        "Condemn The Witch": "Training to resist and combat psykers",
        "Contortionist": "Exceptional bodily flexibility",
        "Counter Attack": "Expertise in defensive combat",
        "Coup De Grace": "Skilled at finishing enemies",
        "Data Delver": "Expert at information extraction",
        "Deadeye": "Exceptional marksmanship",
        "Dealmaker": "Natural negotiator and trader",
        "Demolition Specialist": "Expert with explosives",
        "Devoted Servant": "Unwavering loyalty to cause",
        "Directed Strikes": "Precision targeting in combat",
        "Dirty Fighting": "Underhanded combat techniques",
        "Disarm": "Expertise in removing enemy weapons",
        "Disturbing Voice": "Unsettling vocal presence",
        "Distracting": "Ability to misdirect attention",
        "Drilled": "Military training and discipline",
        "Dual Wielder": "Fighting with two weapons",
        "Duellist": "Formal combat training",
        "Eidetic Memory": "Perfect recall of information",
        "Ever Vigilant": "Constant alertness to danger",
        "Exploit Vulnerability": "Finding and using weaknesses",
        "Extended Proprioception": "Enhanced spatial awareness",
        "False Retreat": "Tactical feinting in combat",
        "Faithful": "Unwavering religious devotion",
        "Familiar Terrain": "Knowledge of specific environments",
        "Fated": "Blessed by destiny",
        "Field Medicae": "Battlefield medical training",
        "Flagellant": "Self-mortification for spiritual strength",
        "Flanking Fire": "Tactical shooting techniques",
        "Flesh Is Weak": "Mechanical augmentation acceptance",
        "Forbidden Knowledge": "Access to dangerous information",
        "Forger": "Document and identity falsification",
        "Full-Auto Fanatic": "Expertise with automatic weapons",
        "Frenzy": "Berserker rage in combat",
        "Gallows Humour": "Dark wit in dire situations",
        "Gothic Gibberish": "Ability to confuse with words",
        "Guardian": "Protective instincts and training",
        "Gunslinger": "Quick-draw shooting expertise",
        "Hatred": "Focused animosity toward specific foes",
        "Hit And Run": "Mobile combat tactics",
        "Holdout Expert": "Concealing weapons and items",
        "Hypno-Indoctrination": "Mental conditioning resistance",
        "Icon Bearer": "Inspiring presence through symbols",
        "Ignorance Is My Shield": "Protection through lack of knowledge",
        "Inspiring Presence": "Motivating others in crisis",
        "Inheritor": "Noble birthright and training",
        "Lawbringer": "Authority and justice expertise",
        "Lickspittle": "Obsequious flattery skills",
        "Martyrdom": "Willingness to sacrifice for cause",
        "Medicae Maverick": "Unconventional medical techniques",
        "Mental Fortress": "Psychic resistance training",
        "Mimic": "Voice and mannerism imitation",
        "Overseer": "Management and supervision skills",
        "Pathologist": "Disease and death expertise",
        "Phlebotomist": "Blood and bodily fluid knowledge",
        "Porter": "Enhanced carrying capacity",
        "Psychic Castigation": "Mental attack techniques",
        "Psychic Flood": "Overwhelming psychic assault",
        "Psyker": "Warp-touched abilities",
        "Quickdraw": "Lightning-fast weapon deployment",
        "Rapid Reload": "Fast ammunition replacement",
        "Read Lips": "Understanding speech without hearing",
        "Registered Trader": "Commercial licensing and connections",
        "Sanctioned Psyker": "Official psychic training",
        "Secret Identity": "Maintaining false personas",
        "Shock Assault": "Overwhelming first strike",
        "Skulker": "Stealth and hiding expertise",
        "Slippery": "Escape and evasion skills",
        "Superior Commander": "Advanced leadership training",
        "Suppressing Fire": "Area denial shooting",
        "Sure-Footed": "Balance and terrain navigation",
        "Tactical Movement": "Combat positioning expertise",
        "Tenacious": "Stubborn determination",
        "Two-Handed Cleave": "Heavy weapon techniques",
        "Unflinching Presence": "Intimidating demeanor",
        "Unremarkable": "Ability to blend into crowds",
        "Void Legs": "Adaptation to zero gravity",
        "Well-Prepared": "Thorough planning and preparation"
    ]
    
    static let allTalents = Array(talents.keys).sorted()
}
