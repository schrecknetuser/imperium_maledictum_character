//
//  CriticalWoundModel.swift
//  ImperiumMaledictumCharacter
//
//  Created by User on 11.01.2025.
//

import Foundation

struct CriticalWound: Codable, Identifiable {
    var id: UUID = UUID()
    let name: String
    let description: String
    let treatment: String
    
    init(name: String, description: String, treatment: String) {
        self.id = UUID()
        self.name = name
        self.description = description
        self.treatment = treatment
    }
    
    enum CodingKeys: String, CodingKey {
        case name, description, treatment
    }
}

// MARK: - Critical Wound Definitions

struct CriticalWoundDefinitions {
    
    static let headWounds = [
        CriticalWound(
            name: "Black Eye",
            description: "You are struck in the eye. You have Disadvantage on Awareness (Sight) and Ranged Tests for 1 hour.",
            treatment: "None."
        ),
        CriticalWound(
            name: "Rattling Blow",
            description: "The blow floods your vision with flashing lights. You are Stunned until the end of your next turn.",
            treatment: "None."
        ),
        CriticalWound(
            name: "Laceration",
            description: "You suffer a laceration to the cheek. You are Bleeding.",
            treatment: "A Routine (+20) Medicae Test to stop the Bleeding; application of bandages; or the laceration will close naturally after 1 hour."
        ),
        CriticalWound(
            name: "Sliced Ear",
            description: "The attack slices your ear, leaving your ears ringing. You are Deafened until the end of your next turn, and are Bleeding.",
            treatment: "A Challenging (+0) Medicae Test to stop the Bleeding; application of bandages; or the laceration will close naturally after 1 hour."
        ),
        CriticalWound(
            name: "Dislocated Jaw",
            description: "The blow strikes you in the face, dislocating your jaw. You are Stunned until the end of your next turn, and have Disadvantage on Rapport Tests and Tests that rely on speech. Injury: Your jaw is cracked. You suffer a Broken Bone (Minor) Injury to your jaw.",
            treatment: "A Challenging (+0) Medicae Test to relocate the jaw."
        ),
        CriticalWound(
            name: "Struck Forehead",
            description: "You are struck in the head, causing blood to run down your face and impair your vision. You are Blinded and Bleeding.",
            treatment: "A Challenging (+0) Medicae Test to stop the Bleeding; application of bandages; or the laceration will close naturally after 1 hour."
        ),
        CriticalWound(
            name: "Major Eye Wound",
            description: "You are hit in the eye, causing serious damage. You are Bleeding, and have Disadvantage on Awareness (Sight) Tests. If you only have one eye, you are Blinded. Injury: Your orbital bone is shattered. You suffer a Broken Bone (Major) Injury to your eye.",
            treatment: "A Difficult (−10) Medicae Test to treat the eye and stop the Bleeding."
        ),
        CriticalWound(
            name: "Major Ear Wound",
            description: "The blow strikes you in the ear or otherwise damages your ear drums. You are Deafened. If you suffer this result again, your hearing is permanently lost.",
            treatment: "A Difficult (−10) Medicae Test, usually using drugs to reduce swelling and inflammation in the ear."
        ),
        CriticalWound(
            name: "Smashed Mouth",
            description: "The blow smashes out several teeth. You are Bleeding and must make a Challenging (+0) Fortitude (Pain) Test or also fall Prone. Injury: You lose 1d10 teeth. You suffer the Amputation (Teeth) Injury.",
            treatment: "A Difficult (−10) Medicae Test performed by someone with the Chirurgeon Talent or similar expertise."
        ),
        CriticalWound(
            name: "Broken Nose",
            description: "You are struck in the nose, shattering the bone and filling your eyes with tears. You also gain the Bleeding (Major) Condition. Additionally, you are Blinded until the end of your next turn, and must make a Challenging (+0) Fortitude (Pain) Test or become Stunned until the end of your next turn. Injury: Your nose is shattered. You suffer a Broken Bone (Major) Injury to your nose.",
            treatment: "A Hard (−20) Medicae Test using a chirurgeon's kit to stop the Bleeding."
        ),
        CriticalWound(
            name: "Mangled Ear",
            description: "The blow tears your ear apart. You are Deafened and Bleeding (Major). You must make a Challenging (+0) Fortitude (Pain) Test or also gain the Stunned Condition until the end of your next turn. Injury: Your ear is torn off. You suffer the Amputation (Ear) Injury.",
            treatment: "A Hard (−20) Medicae Test performed by someone with the Chirurgeon Talent or similar expertise."
        ),
        CriticalWound(
            name: "Concussive Blow",
            description: "You take a concussive blow to the head. You are Deafened and Stunned for 1 minute, and are Bleeding. Injury: You are concussed, and are Fatigued for 1d10 days regardless of how much rest you take.",
            treatment: "A Hard (−20) Medicae Test using a chirurgeon's kit to stop the Bleeding and restore hearing."
        ),
        CriticalWound(
            name: "Devastated Eye",
            description: "A strike to your eye causes it to burst. You are Bleeding (Major), and have Disadvantage on Awareness (Sight) Tests. If you only have one eye, you are Blinded. Injury: You lose your eye. You suffer the Amputation (Eye) Injury.",
            treatment: "A Very Hard (−30) Medicae Test performed by someone with the Chirurgeon Talent or similar expertise."
        ),
        CriticalWound(
            name: "Mangled Jaw",
            description: "The blow shatters your jaw and destroys your tongue, sending teeth flying. You are Bleeding (Major). You must make a Challenging (+0) Fortitude (Pain) Test. On a success you are Stunned until the end of your next turn; on a failure you are Incapacitated until the end of your next turn and fall Prone. Injury: You lose 1d10 teeth, and suffer the Amputation (Teeth) Injury. Additionally, your jaw is shattered, and you suffer the Broken Bone (Major) Injury to your jaw.",
            treatment: "A Very Hard (−30) Medicae Test performed by someone with the Chirurgeon Talent or similar expertise."
        ),
        CriticalWound(
            name: "Shattered Skull",
            description: "Your head is caved in or erupts in a shower of bone and gore. You are dead.",
            treatment: "None."
        )
    ]
    
    static let armWounds = [
        CriticalWound(
            name: "Jolted Wrist",
            description: "You are struck in the wrist, jarring your hand. Drop any item held in the hand.",
            treatment: "None."
        ),
        CriticalWound(
            name: "Dead Arm",
            description: "You are struck by a rattling blow in your arm, causing it to temporarily go numb. You have Disadvantage on all Tests using the arm for 1 minute.",
            treatment: "None."
        ),
        CriticalWound(
            name: "Laceration",
            description: "You suffer a laceration to the arm. You are Bleeding.",
            treatment: "A Routine (+20) Medicae Test to stop the Bleeding; application of bandages; or the laceration will close naturally after 1 hour."
        ),
        CriticalWound(
            name: "Sliced Hand",
            description: "Your hand is sliced open, sending jolts of pain through your arm. You are Bleeding and drop any item held in the hand.",
            treatment: "A Challenging (+0) Medicae Test to stop the Bleeding; application of bandages; or the laceration will close naturally after 1 hour."
        ),
        CriticalWound(
            name: "Dislocated Shoulder",
            description: "The strike dislocates your shoulder from the socket. The arm is useless until popped back into place. At the start of each turn while you have a dislocated shoulder you must make a Challenging (+0) Fortitude (Pain) Test. On a failure, you are Stunned until the start of your next turn.",
            treatment: "A Challenging (+0) Medicae Test to pop the shoulder back into place."
        ),
        CriticalWound(
            name: "Severed Finger",
            description: "The attack tears off one of your fingers. You are Bleeding (Major). Injury: One of your fingers is torn off. You suffer the Amputation (Finger) Injury.",
            treatment: "A Challenging (+0) Medicae Test performed by someone with the Chirurgeon Talent."
        ),
        CriticalWound(
            name: "Clean Break",
            description: "The attack fractures a bone in your arm. Your arm is completely useless, and you drop any item held. You must make a Challenging (+0) Fortitude (Pain) Test or be Stunned for one minute. Injury: Your arm is broken. You suffer the Broken Bone (Minor) Injury to your arm.",
            treatment: "A Difficult (−10) Medicae Test to treat shock. This Test does not treat the break."
        ),
        CriticalWound(
            name: "Deep Cut",
            description: "You suffer a deep gash on your arm, reducing your effectiveness. You are Bleeding (Major) and have Disadvantage on all Tests using the arm.",
            treatment: "A Difficult (−10) Medicae Test using a chirurgeon's kit to stop the Bleeding."
        ),
        CriticalWound(
            name: "Mangled Hand",
            description: "The blow devastates your hand, breaking bones and potentially severing fingers. You are Bleeding (Major) and immediately drop any item held. Injury: Your hand is crushed. You suffer the Broken Bone (Major) Injury to your hand. Additionally, you lose 1d10 − 5 fingers. If your result is 0, you manage to keep all of your digits. Otherwise, you suffer the Amputation (Fingers) Injury.",
            treatment: "A Difficult (−10) Medicae Test performed by someone with the Chirurgeon Talent."
        ),
        CriticalWound(
            name: "Shattered Elbow",
            description: "The attack shatters the bones in your elbow. Your arm is completely useless, and you immediately drop any item held in the hand. Additionally, you must make a Difficult (−10) Fortitude (Pain) Test or be Stunned for one minute. Injury: Your arm is broken. You suffer the Broken Bone (Major) Injury to your arm.",
            treatment: "A Hard (−20) Medicae Test to treat shock. This Test does not count as treating the broken bone."
        ),
        CriticalWound(
            name: "Cleft Hand",
            description: "Your hand is splayed apart, causing a major injury and severing fingers. You are Bleeding (Major) and immediately drop any item held in the hand. Additionally, you must make a Difficult (−10) Fortitude (Pain) Test or be Stunned for one minute. Injury: You lose a finger. You suffer the Amputation (Finger) Injury. For each minute the Critical Wound is untreated, you lose an additional finger. If you lose all fingers on the hand, you instead gain the Amputation (Hand) Injury.",
            treatment: "A Hard (−20) Medicae Test performed by someone with the Chirurgeon Talent or similar expertise."
        ),
        CriticalWound(
            name: "Sliced Artery",
            description: "You suffer a serious wound to a major artery. You are Bleeding (Major), Fatigued from blood loss, your arm is completely useless, and you immediately drop any item held in the hand. Injury: Due to blood loss, you are Fatigued for 1d10 days regardless of how much rest you take.",
            treatment: "A Hard (−20) Medicae Test using a chirurgeon's kit to stop the Bleeding."
        ),
        CriticalWound(
            name: "Severed Hand",
            description: "Your hand is taken clean off. You are Bleeding (Major) and Stunned for 1 hour. Injury: You lose a hand. You suffer the Amputation (Hand) Injury.",
            treatment: "A Very Hard (−30) Medicae Test performed by someone with the Chirurgeon Talent or similar expertise."
        ),
        CriticalWound(
            name: "Ruined Arm",
            description: "Your arm is mangled and torn apart, with only the barest piece of flesh attaching it to your body. Your arm is completely useless, and you immediately drop any item held in the hand. You are Bleeding (Major) and Stunned for 1 hour. If you suffer any further Damage to the arm, you automatically suffer the Brutal Dismemberment Critical Wound and die. Injury: Your arm is hanging on by a thread and must be amputated. You suffer the Amputation (Arm) Injury.",
            treatment: "A Very Hard (−30) Medicae Test performed by someone with the Chirurgeon Talent or similar expertise to fully remove the arm."
        ),
        CriticalWound(
            name: "Brutal Dismemberment",
            description: "Your arm is completely destroyed and torn from your body, causing shock and catastrophic blood loss. You are dead.",
            treatment: "None."
        )
    ]
    
    static let bodyWounds = [
        CriticalWound(
            name: "Winded",
            description: "The blow knocks the wind out of you. You are Stunned until the end of your next turn.",
            treatment: "None."
        ),
        CriticalWound(
            name: "Low Blow",
            description: "You are struck in a sensitive area. You must make a Challenging (+0) Fortitude (Pain) Test or fall Prone.",
            treatment: "None."
        ),
        CriticalWound(
            name: "Laceration",
            description: "You suffer a laceration to the body. You are Bleeding.",
            treatment: "An Routine (+20) Medicae Test to stop the bleeding; application of bandages; or the laceration will close naturally after 1 hour."
        ),
        CriticalWound(
            name: "Gut Shot",
            description: "You are hit hard in the stomach. You are Bleeding and knocked Prone.",
            treatment: "A Challenging (+0) Medicae Test to stop the bleeding; application of bandages; or the laceration will close naturally after 1 hour."
        ),
        CriticalWound(
            name: "Cracked Rib",
            description: "The attack cracks one of your ribs. You have Disadvantage on Strength and Agility Tests, and your Move is reduced one step. Injury: You have a cracked rib. You suffer the Broken Bone (Minor) Injury to your torso.",
            treatment: "None."
        ),
        CriticalWound(
            name: "Hammering Blow",
            description: "You are thrown back by the force of the blow. You are Stunned for 1 minute and are Bleeding.",
            treatment: "A Challenging (+0) Medicae Test performed by someone with the Chirurgeon Talent."
        ),
        CriticalWound(
            name: "Broken Collarbone",
            description: "You suffer a crunching blow to your collarbone — determine randomly if this is on your left or right. You drop any item held in the hand on that side and have Disadvantage on all Tests using the arm. Additionally, you must make a Challenging (+0) Fortitude (Pain) Test or be Stunned for one minute. Injury: Your collarbone is broken. You suffer the Broken Bone (Minor) Injury to your collarbone, which is treated as a broken arm.",
            treatment: "A Difficult (−10) Medicae Test to treat shock. This Test does not count as treating the broken bone."
        ),
        CriticalWound(
            name: "Deep Cut",
            description: "You suffer a deep cut on your lower abdomen, which makes it difficult to move. You are Bleeding (Major), and your Speed is reduced one step.",
            treatment: "A Difficult (−10) Medicae Test using a chirurgeon's kit to stop the bleeding."
        ),
        CriticalWound(
            name: "Fractured Hip",
            description: "You are hit in the hip, causing the bone to fracture. You are knocked Prone, have Disadvantage on Tests that rely on mobility, and your Move is reduced one step. Additionally, you must make a Challenging (+0) Fortitude (Pain) Test or be Stunned for one minute. Injury: Your hip is fractured. You suffer the Broken Bone (Minor) Injury to your hip, which is treated as a broken leg.",
            treatment: "A Difficult (−10) Medicae Test to treat shock. This Test does not count as treating the broken bone."
        ),
        CriticalWound(
            name: "Shattered Ribs",
            description: "The attack shatters multiple ribs, leaving shards of bone peppered throughout your flesh. You have Disadvantage on any physical Test, and your Move is reduced two steps to a minimum of Slow. Injury: You suffer a Broken Bone (Major) Injury to your torso.",
            treatment: "A Difficult (−10) Medicae Test to treat shock. This Test does not count as treating the broken bone."
        ),
        CriticalWound(
            name: "Punctured Lung",
            description: "The attack punctures your lung, perhaps embedding shrapnel, a bullet, or a fragment of your own bone. You gain a Fatigued Condition and a Bleeding (Minor) Condition. Injury: Your lung is badly damaged and partially filled with fluids. A Difficult (−10) Medicae Test performed by someone with the Chirurgeon Talent is required to repair the damaged tissue and remove the Fatigued Condition.",
            treatment: "A Difficult (−10) Medicae Test to patch up the wound and remove the Bleeding Condition."
        ),
        CriticalWound(
            name: "Sliced Artery",
            description: "You suffer a serious wound to a major artery. You are Bleeding (Major), Fatigued from blood loss, have Disadvantage on Tests that rely on mobility, your Move is reduced one step, and you fall Prone. Injury: Due to blood loss, you are Fatigued for 1d10 days regardless of how much rest you take.",
            treatment: "A Hard (−20) Medicae Test using a chirurgeon's kit to stop the bleeding."
        ),
        CriticalWound(
            name: "Flayed Flesh",
            description: "A chunk of the flesh of your torso is blasted away, leaving an ugly, open wound that exposes the bones and organs beneath. You are Bleeding (Major) and Prone. Additionally, you are Stunned for 1 hour. Injury: A Difficult (−10) Medicae Test performed by someone with the Chirurgeon Talent is required to repair the damaged tissue.",
            treatment: "A Very Hard (−30) Medicae Test performed by someone with the Chirurgeon Talent or similar expertise."
        ),
        CriticalWound(
            name: "Injured Spine",
            description: "You suffer a substantial injury to your spine, making it difficult to stand and leaves you in terrible pain. You are Bleeding (Major) and Prone. Injury: Your spine is cracked or broken. You suffer the Broken Bone (Major) Injury to your torso.",
            treatment: "A Very Hard (−30) Medicae Test performed by someone with the Chirurgeon Talent or similar expertise."
        ),
        CriticalWound(
            name: "Torn Apart",
            description: "You are split in two or otherwise torn apart. Creatures within Short Range are showered in blood and gore. You are dead.",
            treatment: "None."
        )
    ]
    
    static let legWounds = [
        CriticalWound(
            name: "Twisted Ankle",
            description: "You twist your ankle, causing you to stumble. You fall Prone.",
            treatment: "None."
        ),
        CriticalWound(
            name: "Dead Leg",
            description: "You are struck by a rattling blow in your leg, causing it to temporarily go numb. Your Speed is reduced one step for 1 minute.",
            treatment: "None."
        ),
        CriticalWound(
            name: "Laceration",
            description: "You suffer a laceration to the leg. You are Bleeding.",
            treatment: "A Routine (+20) Medicae Test to stop the Bleeding; application of bandages; or the laceration will close naturally after 1 hour."
        ),
        CriticalWound(
            name: "Sliced Calf",
            description: "Your calf is sliced open, sending jolts of pain through your leg. You are Bleeding and fall Prone.",
            treatment: "A Challenging (+0) Medicae Test to stop the Bleeding; apply bandages; or wait 1 hour."
        ),
        CriticalWound(
            name: "Dislocated Knee",
            description: "The strike dislocates your knee. You have Disadvantage on Tests that rely on mobility, and your Move is reduced one step. At the start of each turn while you have a dislocated knee you must make a Challenging (+0) Fortitude (Pain) Test. On a failure, you are Stunned until the start of your next turn.",
            treatment: "A Challenging (+0) Medicae Test to pop the knee back into place."
        ),
        CriticalWound(
            name: "Severed Toe",
            description: "The attack tears off one of your toes. You are Bleeding (Major). Injury: One of your toes is torn off. You suffer the Amputation (Toe) Injury.",
            treatment: "A Challenging (+0) Medicae Test performed by someone with the Chirurgeon Talent."
        ),
        CriticalWound(
            name: "Clean Break",
            description: "The attack fractures a bone in your leg. Your leg is completely useless, you immediately fall Prone, you have Disadvantage on Tests that rely on mobility, and your Move is reduced one step. Additionally, you must make a Challenging (+0) Fortitude (Pain) Test or be Stunned for one minute. Injury: Your leg is broken. You suffer the Broken Bone (Minor) Injury to your leg.",
            treatment: "A Difficult (−10) Medicae Test to treat shock. This Test does not count as treating the broken bone."
        ),
        CriticalWound(
            name: "Deep Cut",
            description: "You suffer a deep gash on your leg, reducing your effectiveness. You are Bleeding (Major) and have Disadvantage on all Tests using the leg, such as jumping or climbing.",
            treatment: "A Difficult (−10) Medicae Test using a chirurgeon's kit to stop the Bleeding."
        ),
        CriticalWound(
            name: "Mangled Foot",
            description: "The blow devastates your foot, breaking bones and potentially severing toes. You are Bleeding (Major), immediately fall Prone, and your Move is reduced one step. Injury: Your foot is crushed. You suffer the Broken Bone (Major) Injury to your foot. Additionally, you lose 1d10 − 5 toes. If your result is 0, you manage to keep all of your digits. Otherwise, you suffer the Amputation (Toes) Injury.",
            treatment: "A Difficult (−10) Medicae Test performed by someone with the Chirurgeon Talent."
        ),
        CriticalWound(
            name: "Shattered Knee",
            description: "The attack shatters the bones in your knee. Your leg is completely useless, you immediately fall Prone, your Move is reduced one step, you have Disadvantage on Tests that rely on mobility. You must make a Difficult (−10) Fortitude (Pain) Test or be Stunned for one minute. Injury: Your leg is broken. You suffer the Broken Bone (Major) Injury to your leg.",
            treatment: "A Hard (−20) Medicae Test to treat shock. This Test does not count as treating the broken bone."
        ),
        CriticalWound(
            name: "Cleft Foot",
            description: "Your foot is splayed apart, causing a major injury and severing toes. You are Bleeding (Major) and immediately fall Prone. Additionally, you must make a Difficult (−10) Fortitude (Pain) Test or be Stunned for one minute. Injury: You lose a toe. You suffer the Amputation (Toe) Injury. For each minute the Critical Wound is untreated, you lose an additional toe. If you lose all toes on the foot, you instead gain the Amputation (Foot) Injury.",
            treatment: "A Hard (−20) Medicae Test performed by someone with the Chirurgeon Talent or similar expertise."
        ),
        CriticalWound(
            name: "Sliced Artery",
            description: "You suffer a serious wound to a major artery. You are Bleeding (Major), Fatigued from blood loss, have Disadvantage on Tests that rely on mobility, your Move is reduced one step, and you fall Prone. Injury: Due to blood loss, you are Fatigued for 1d10 days regardless of how much rest you take.",
            treatment: "A Hard (−20) Medicae Test using a chirurgeon's kit to stop the Bleeding."
        ),
        CriticalWound(
            name: "Severed Foot",
            description: "Your foot is taken clean off. You are Bleeding (Major) and Prone. Additionally, you are Stunned for 1 hour. Injury: You lose a foot. You suffer the Amputation (Foot) Injury.",
            treatment: "A Very Hard (−30) Medicae Test performed by someone with the Chirurgeon Talent."
        ),
        CriticalWound(
            name: "Ruined Leg",
            description: "Your leg is mangled and torn apart, with only the barest piece of flesh attaching it to your body. Your leg is completely useless, you fall Prone, your Move is reduced one step, and have Disadvantage on Tests that rely on mobility. You are Bleeding (Major) and Stunned for 1 hour. If you suffer any further Damage to the leg, you automatically suffer the Brutal Dismemberment Critical Wound and die. Injury: Your leg is hanging on by a thread and must be amputated. You suffer the Amputation (Leg) Injury.",
            treatment: "A Very Hard (−30) Medicae Test performed by someone with the Chirurgeon Talent or similar expertise to fully remove the leg."
        ),
        CriticalWound(
            name: "Brutal Dismemberment",
            description: "Your leg is completely destroyed and torn from your body, causing shock and catastrophic blood loss. You are dead.",
            treatment: "None."
        )
    ]
}