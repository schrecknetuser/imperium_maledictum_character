//
//  EquipmentModel.swift
//  ImperiumMaledictumCharacter
//
//  Created by User on 11.01.2025.
//

import Foundation

class Equipment: Codable {
    var name: String
    var equipmentDescription: String
    var encumbrance: Int
    var cost: Int
    var availability: String
    var qualitiesData: String // JSON array of strings
    var flawsData: String // JSON array of strings
    var traitsData: String // JSON array of EquipmentTrait
    
    var qualities: [String] {
        get {
            guard let data = qualitiesData.data(using: .utf8),
                  let decoded = try? JSONDecoder().decode([String].self, from: data) else {
                return []
            }
            return decoded
        }
        set {
            if let encoded = try? JSONEncoder().encode(newValue) {
                qualitiesData = String(data: encoded, encoding: .utf8) ?? ""
            }
        }
    }
    
    var flaws: [String] {
        get {
            guard let data = flawsData.data(using: .utf8),
                  let decoded = try? JSONDecoder().decode([String].self, from: data) else {
                return []
            }
            return decoded
        }
        set {
            if let encoded = try? JSONEncoder().encode(newValue) {
                flawsData = String(data: encoded, encoding: .utf8) ?? ""
            }
        }
    }
    
    var traits: [EquipmentTrait] {
        get {
            guard let data = traitsData.data(using: .utf8),
                  let decoded = try? JSONDecoder().decode([EquipmentTrait].self, from: data) else {
                return []
            }
            return decoded
        }
        set {
            if let encoded = try? JSONEncoder().encode(newValue) {
                traitsData = String(data: encoded, encoding: .utf8) ?? ""
            }
        }
    }
    
    init(name: String, equipmentDescription: String = "", encumbrance: Int = 0, cost: Int = 0, availability: String = "Common") {
        self.name = name
        self.equipmentDescription = equipmentDescription
        self.encumbrance = encumbrance
        self.cost = cost
        self.availability = availability
        self.qualitiesData = ""
        self.flawsData = ""
        self.traitsData = ""
    }
}

struct EquipmentTrait: Codable {
    var name: String
    var traitDescription: String
    var parameter: String
    
    var displayName: String {
        return parameter.isEmpty ? name : "\(name) (\(parameter))"
    }
    
    init(name: String, traitDescription: String = "", parameter: String = "") {
        self.name = name
        self.traitDescription = traitDescription
        self.parameter = parameter
    }
}

// MARK: - Equipment Constants
struct EquipmentQualities {
    static let lightweight = "Lightweight"
    static let masterCrafted = "Master Crafted"
    static let ornamental = "Ornamental"
    static let durable = "Durable"
    
    static let all = [lightweight, masterCrafted, ornamental, durable]
}

struct EquipmentFlaws {
    static let bulky = "Bulky"
    static let shoddy = "Shoddy"
    static let ugly = "Ugly"
    static let unreliable = "Unreliable"
    
    static let all = [bulky, shoddy, ugly, unreliable]
}

struct EquipmentTraitNames {
    static let blast = "Blast"
    static let burst = "Burst"
    static let close = "Close"
    static let defensive = "Defensive"
    static let flamer = "Flamer"
    static let heavy = "Heavy"
    static let ineffective = "Ineffective"
    static let inflict = "Inflict"
    static let loud = "Loud"
    static let penetrating = "Penetrating"
    static let rapidFire = "Rapid Fire"
    static let reach = "Reach"
    static let reliable = "Reliable"
    static let rend = "Rend"
    static let shield = "Shield"
    static let spread = "Spread"
    static let subtle = "Subtle"
    static let supercharge = "Supercharge"
    static let thrown = "Thrown"
    static let twoHanded = "Two-Handed"
    static let unstable = "Unstable"
    
    static let all = [
        blast, burst, close, defensive, flamer, heavy, ineffective,
        inflict, loud, penetrating, rapidFire, reach, reliable, rend,
        shield, spread, subtle, supercharge, thrown, twoHanded, unstable
    ]
}

struct AvailabilityLevels {
    static let common = "Common"
    static let rare = "Rare"
    static let scarce = "Scarce"
    static let exotic = "Exotic"
    
    static let all = [common, rare, scarce, exotic]
}

// MARK: - Equipment Categories
struct EquipmentCategories {
    static let clothingPersonalGear = "Clothing & Personal Gear"
    static let tools = "Tools"
    static let forceFields = "Force Fields"
    static let augmetics = "Augmetics"
    
    static let all = [clothingPersonalGear, tools, forceFields, augmetics]
}

// MARK: - Equipment Template System
struct EquipmentTemplate {
    var name: String
    var category: String
    var description: String
    var encumbrance: Int
    var cost: Int
    var availability: String
    var qualities: [String]
    var flaws: [String]
    var traits: [EquipmentTrait]
    
    init(name: String, category: String, description: String = "", encumbrance: Int = 0, cost: Int = 0, availability: String = "Common", qualities: [String] = [], flaws: [String] = [], traits: [EquipmentTrait] = []) {
        self.name = name
        self.category = category
        self.description = description
        self.encumbrance = encumbrance
        self.cost = cost
        self.availability = availability
        self.qualities = qualities
        self.flaws = flaws
        self.traits = traits
    }
    
    func createEquipment() -> Equipment {
        let equipment = Equipment(
            name: name,
            equipmentDescription: description,
            encumbrance: encumbrance,
            cost: cost,
            availability: availability
        )
        equipment.qualities = qualities
        equipment.flaws = flaws
        equipment.traits = traits
        return equipment
    }
}

struct EquipmentTemplateDefinitions {
    // MARK: - Force Fields
    static let forceFields: [EquipmentTemplate] = [
        EquipmentTemplate(
            name: "Refractor Field",
            category: EquipmentCategories.forceFields,
            description: "A personal force field that provides protection against incoming attacks.",
            encumbrance: 0,
            cost: 1000,
            availability: AvailabilityLevels.exotic,
            traits: [
                EquipmentTrait(name: "Protection", traitDescription: "Provides protective force field", parameter: "1d10"),
                EquipmentTrait(name: "Overload", traitDescription: "Field overload threshold", parameter: "10")
            ]
        ),
        EquipmentTemplate(
            name: "Conversion Field",
            category: EquipmentCategories.forceFields,
            description: "An advanced personal force field with enhanced protection capabilities.",
            encumbrance: 0,
            cost: 6000,
            availability: AvailabilityLevels.exotic,
            traits: [
                EquipmentTrait(name: "Protection", traitDescription: "Provides protective force field", parameter: "2d10"),
                EquipmentTrait(name: "Overload", traitDescription: "Field overload threshold", parameter: "20")
            ]
        )
    ]
    
    // MARK: - Clothing and Personal Gear
    static let clothingPersonalGear: [EquipmentTemplate] = [
        EquipmentTemplate(
            name: "Backpack/Slings",
            category: EquipmentCategories.clothingPersonalGear,
            description: "When worn, a backpack or sling increases your maximum Encumbrance by 4.",
            encumbrance: 1,
            cost: 20,
            availability: AvailabilityLevels.common
        ),
        EquipmentTemplate(
            name: "Cameleoline Cloak",
            category: EquipmentCategories.clothingPersonalGear,
            description: "The choice of garb for snipers and thieves alike, this cloak covers the entire body and uses exotic mimic fibres that automatically shift colouration to match the surroundings. If you do not move during your turn while wearing a Cameleoline Cloak, you gain +2 SL on Stealth Tests until you move or make a loud noise.",
            encumbrance: 0,
            cost: 500,
            availability: AvailabilityLevels.rare
        ),
        EquipmentTemplate(
            name: "Explosive Collar",
            category: EquipmentCategories.clothingPersonalGear,
            description: "Though most often seen around the necks of penal legionnaires such as the infamous Ghasts of Voll, explosive collars are often also part of the standard kit for many bounty hunters and even for transporting dangerous Macharian psykers onto the Black Ships. These devices are exactly what their name suggests; each has an integral grenade or other explosive within it which can be detonated if improperly removed or via remote action.\nExplosive collars come with a Remote Detonator which sets off a miniature Krak Grenade placed against the back of the neck, automatically killing the wearer. Attaching an Explosive Collar requires that the target is unconscious or Incapacitated (see page 358) for at least 1 minute. Removing the collar requires a Very Hard (−30) Tech (Engineering) Test; this Test is made with Disadvantage if the wearer is attempting this.",
            encumbrance: 0,
            cost: 150,
            availability: AvailabilityLevels.scarce
        ),
        EquipmentTemplate(
            name: "Filtration Plugs",
            category: EquipmentCategories.clothingPersonalGear,
            description: "These items are simple to manufacture and use. They come in pairs and are each set within the nostril to eliminate noxious pollutants and harmful gases (so long as the user remembers to not breathe through their mouth).\nWhile using filtration plugs, you gain +2 SL on Fortitude Tests made to withstand the effects of harmful gases, such as in Zones with the Hazard Trait.",
            encumbrance: 0,
            cost: 20,
            availability: AvailabilityLevels.common
        ),
        EquipmentTemplate(
            name: "Photo-Visors/Contacts",
            category: EquipmentCategories.clothingPersonalGear,
            description: "Worn either as covering over both eyes or directly on the cornea (where they might be less obvious to others), these devices amplify ambient light to a degree similar to normal illumination.\nWhile wearing Photo-Visors or Photo-Contacts, you ignore penalties from Zones with the Poorly Lit and Dark Environmental Traits, and gain Advantage on Tests to resist effects that cause the Blinded Condition.",
            encumbrance: 0,
            cost: 300,
            availability: AvailabilityLevels.scarce
        ),
        EquipmentTemplate(
            name: "Rebreather",
            category: EquipmentCategories.clothingPersonalGear,
            description: "Rebreathers employ small air tanks as well as recycling systems so that the user can breathe normally for some time in toxic atmospheres and even underwater.\nWhile using a rebreather, you ignore penalties due to poisonous, deadly, and otherwise unhealthy air, and can breathe underwater. Rebreather tanks last for an hour before they need to be replaced as an Action. Additional tanks cost 20 solars.",
            encumbrance: 1,
            cost: 200,
            availability: AvailabilityLevels.scarce
        ),
        EquipmentTemplate(
            name: "Respirator/Gas Mask",
            category: EquipmentCategories.clothingPersonalGear,
            description: "A basic item for operating for extended durations in toxic atmospheres, respirators and gas masks cover the majority of the face and offer much greater protection than Filtration Plugs, at the cost of being bulky and obscuring the senses.\nWhile wearing a Respirator, you automatically pass any Tests to resist the effects of airborne pathogens but suffer Disadvantage on Awareness (Sight) Tests.",
            encumbrance: 0,
            cost: 50,
            availability: AvailabilityLevels.common
        ),
        EquipmentTemplate(
            name: "Survival Gear",
            category: EquipmentCategories.clothingPersonalGear,
            description: "Survival gear encompasses a wide range of equipment designed for long durations in wilderness areas, including the crumbling habways of destroyed cities and other areas where basic necessities are unavailable. Though bulky, they can mean the difference between life and death in areas where no one might ever find the remains.\nEach Survival Gear pack includes items such as a bedroll, insulated tent, canteen, rope, firestarters, candles, hydro-purifier tabs, and other basics except for actual food and water. Survival gear is used in combination with Fortitude (Endurance) to endure Exposure (see page 218).",
            encumbrance: 3,
            cost: 50,
            availability: AvailabilityLevels.common
        ),
        EquipmentTemplate(
            name: "Synskin",
            category: EquipmentCategories.clothingPersonalGear,
            description: "Synskin is a highly advanced tight-fitting body glove made of spectrally inert non-reflective fabrics that also dissipate or mask heat signatures to allow the wearer to disappear into the dark as well as provide a modicum of protection against attackers who do manage to detect them.\nSynskin counts as an Armoured Bodyglove, page 141. In addition, if it is not worn in addition to other clothing or armour, the Synskin grants +1 SL to Stealth (Hide) Tests.",
            encumbrance: 0,
            cost: 3000,
            availability: AvailabilityLevels.exotic
        ),
        EquipmentTemplate(
            name: "Void Suit",
            category: EquipmentCategories.clothingPersonalGear,
            description: "Though most commonly found on ships that ply the spaces between planets and stars, the ability of void suits to provide air and other support in a vacuum means they are also worn in extremely hazardous manufactorum areas when breathable air might be lost at any moment. Though usually uncomfortable to wear, the alternative is always worse.\nA void suit allows you to ignore the effects of vacuum and airborne pathogens through an integral rebreather system that lasts 10 hours. Recharging the air supply takes 3 hours while the suit is in a normal atmosphere or by replacing the oxygen canister as an Action. Each canister costs 30 solars each.\nA void suit also contains micro-thrusters and mag boots that let the user navigate in Zero Gravity with relative ease. Additionally, void suits count as armour, granting 3 AP to all locations.",
            encumbrance: 2,
            cost: 2000,
            availability: AvailabilityLevels.scarce
        )
    ]
    
    // MARK: - Tools
    static let tools: [EquipmentTemplate] = [
        EquipmentTemplate(
            name: "Auspex/Scanner",
            category: EquipmentCategories.tools,
            description: "A standard tool of many Imperial agents and warriors, these sensory devices can detect motion, energy emissions, light outside of Human vision, signs of life, and more. They are generally easy to use and invaluable when scouting unfamiliar terrain.\nAn Auspex or Scanner can reveal energy, life signs, movement, and other data within Medium Range. The GM may call for a Tech Test to detect specific phenomena or overcome interference, with the GM making the final determination of Test Difficulty based on the distance to and strength of the source.",
            encumbrance: 1,
            cost: 500,
            availability: AvailabilityLevels.scarce
        ),
        EquipmentTemplate(
            name: "Auto-Quill",
            category: EquipmentCategories.tools,
            description: "These items allow you to transcribe spoken words or copy written ones onto parchment. Auto-Quills work through an impossible complex system of brass mechanisms, ink generators, and vat-grown quills, all with a great exactitude and faster than even a literate scribe.\nWhile you have an Auto-Quill on your person, you can use it to dictate and transcribe spoken word onto parchment, or copy written text and diagrams onto fresh parchment.",
            encumbrance: 0,
            cost: 100,
            availability: AvailabilityLevels.common
        ),
        EquipmentTemplate(
            name: "Chirurgeon's Kit",
            category: EquipmentCategories.tools,
            description: "This is a small, portable pack of autoscalpels, haemo- staunchers, wound sealers, bandages, and other items to aid surgical efforts done outside of proper facilities. Even those with little skill in these matters might be able to save lives with this kit.\nA Chirurgeon's Kit is required to treat many Critical Wounds (see page 214) as well as certain Injuries (see page 214). A Chirurgeon's Kit is also required to gain the benefits of the Chirurgeon Talent (see page 104).\nYou can use the Chirurgeon's Kit five times before it must be replenished. The cost to replenish the Chirurgeon's Kit is equal to half the cost of a Chirurgeons Kit based on its availability (see page 119). Using the Chirurgeon's Kit requires a Medicae Test. Unless stated otherwise, the Difficulty of the Test is Challenging (+0). On a failure, one use of the supplies is consumed to no effect.",
            encumbrance: 1,
            cost: 500,
            availability: AvailabilityLevels.rare
        ),
        EquipmentTemplate(
            name: "Chrono",
            category: EquipmentCategories.tools,
            description: "A Chrono is a basic, though often overlooked, item used to determine the time. Resourceful folk use Chronos to synchronise their actions.\nChronos display the current time and, if the planet supports it, automatically adjust to local time after only a few seconds on the ground.",
            encumbrance: 0,
            cost: 25,
            availability: AvailabilityLevels.common
        ),
        EquipmentTemplate(
            name: "Climbing Harness",
            category: EquipmentCategories.tools,
            description: "This tool set uses a coil of thin but robust rope, an attachment harness, and a multi-anchor to allow the user to rappel or climb with much more safety than they would have otherwise.\nA climbing harness line is 50 metres in length and can support the weight of a Medium-sized creature or object. It takes an Action to set up a climbing harness. Additionally, the harness automatically arrests its payload should it detect the user falling too fast.",
            encumbrance: 2,
            cost: 100,
            availability: AvailabilityLevels.common
        ),
        EquipmentTemplate(
            name: "Combi-Tool",
            category: EquipmentCategories.tools,
            description: "These items feature a plethora of probes, blades, socket plugs, cleaning hooks, and other aids to appease stubborn Machine Spirits and awakening slumbering ones to service.",
            encumbrance: 0,
            cost: 80,
            availability: AvailabilityLevels.common
        ),
        EquipmentTemplate(
            name: "Comm Leech",
            category: EquipmentCategories.tools,
            description: "Comm Leeches tap into airborne signals, whether they are vox messages or data transmissions.\nYou can use a Comm Leech to make a Challenging (+0) Tech Test to intercept electronic signals out to 3 kilometres, with the GM making the final determination of Test Difficulty and distance based on the current circumstances. You can intercept messages a number of minutes long equal to the SL. On a failure, the leech attempt is detected by the transmitter.",
            encumbrance: 1,
            cost: 800,
            availability: AvailabilityLevels.rare
        ),
        EquipmentTemplate(
            name: "Dataslate",
            category: EquipmentCategories.tools,
            description: "Dataslates can be found everywhere in the Imperium and are the most common way to store recorded data of all kinds.\nA Dataslate can store and display multiple text data, picts, and vid files. Each can be locked with a biometric password, requiring a Hard (−20) Tech Test to bypass.",
            encumbrance: 0,
            cost: 50,
            availability: AvailabilityLevels.common
        ),
        EquipmentTemplate(
            name: "Diagnostor",
            category: EquipmentCategories.tools,
            description: "Diagnostors are handheld medicae scanners that can detect and identify most known ailments Humans can suffer from. They are relatively simple to operate, and small enough that they can be mounted onto Servo- Skulls or the wrist.\nYou can use a Diagnostor in combination with Medicae and Perception Tests to reveal an illness or disease in a Human, with the GM determining the Difficulty depending on how rare or exotic the ailment is.",
            encumbrance: 0,
            cost: 300,
            availability: AvailabilityLevels.scarce
        ),
        EquipmentTemplate(
            name: "Disguise Kit",
            category: EquipmentCategories.tools,
            description: "Disguise Kits are filled with makeup sets, facial prosthetics, skin and hair dyes, wigs and facial hair appliances, and more. A Disguise Kit is essential when merely altering your voice and clothing isn't enough to fool guards and pict scanners. It takes 10 minutes to alter your appearance using a Disguise Kit. No Test is required to simply make yourself look different. However, if you are trying to alter your appearance to appear as a member of a particular faction or to impersonate a specific individual, the GM can ask for a Challenging (+0) or harder Dexterity Test.",
            encumbrance: 1,
            cost: 200,
            availability: AvailabilityLevels.scarce
        ),
        EquipmentTemplate(
            name: "Emperor's Tarot",
            category: EquipmentCategories.tools,
            description: "A seemingly ancient set of cards that takes many forms, these tarot decks are said to allow divination of the future. The 'classic' deck consists of 78 psychically- charged liquid-crystal wafers that are said to be linked to the prophetic visions of the Emperor. Each is unique, however, the makeup varies across the galaxy; in Macharian, many decks are said to have fleeting afterminages of Lord Solar that fade before recognition. They are known to change images, which can shift their interpretations and meanings.\nReading the Emperor's Tarot takes one hour, and you must make a Difficult (−10) Discipline Test. You may never spend Fate to modify the results of this Test. If you succeed by +2 SL or more, you glimpse vague portents of a promising future, and immediately recover 1 Fate point. If you fail by −2 SL or more, you glimpse dark paths before you, and immediately lose 1 Fate point. If you Fumble, you must instead burn one Fate point — the Emperor's Tarot is not to be trifled with, and some futures were never meant to be known.\nYou can only read the Emperor's Tarot once per session. If you wish, you can read the Tarot of another willing character, in which case you make the Discipline Test, but apply any modifications to Fate to the character who's Tarot you read. Reading the Emperor's Tarot for a Character who has burned all of their Fate has no effect — whatever their destiny, it is sealed and well beyond the reach of any mortal soothsayer.",
            encumbrance: 0,
            cost: 1000,
            availability: AvailabilityLevels.exotic
        ),
        EquipmentTemplate(
            name: "Entrenching Tool",
            category: EquipmentCategories.tools,
            description: "Perhaps the most basic tool in the Astra Militarum, the standard model has a wide blade ideal for digging trenches, pits, and simply moving sand and dirt from one location to another. Most types are compact and can fold to a size that can be stowed away when marching or fighting.\nAn Entrenching Tool can also be used as an Improvised (One-handed) melee weapon. A properly sharpened Entrenching Tool counts as an Axe instead.",
            encumbrance: 1,
            cost: 25,
            availability: AvailabilityLevels.common
        ),
        EquipmentTemplate(
            name: "Excruciator Kit",
            category: EquipmentCategories.tools,
            description: "Not all subjects readily divulge crucial information, making these kits very useful as a way to encourage them. Excruciator Kits contain chems, needles, neural probes, blades, and other implements to extract essential data when combined with training to separate revealed truths from desperate lies.\nYou can use an Excruciator Kit in combination with Presence (Interrogation) Tests to gain information from an unwilling prisoner.",
            encumbrance: 1,
            cost: 500,
            availability: AvailabilityLevels.rare
        ),
        EquipmentTemplate(
            name: "Glow-Globe/Stablight",
            category: EquipmentCategories.tools,
            description: "The dark spaces within the Macharian Sector demand purifying light, both figuratively and literally. Stablights are hand held and dependable, having illuminated caverns and voidship underdecks for millennia, while glow globes are usually mounted in ceilings or along walls.\nUsing this device removes the Poorly Lit and Dark Traits from your Zone. The device can shine for 5 hours and recharges after 2 hours of non-use, or almost immediately when connected to a standard Imperial power source.",
            encumbrance: 0,
            cost: 15,
            availability: AvailabilityLevels.common
        ),
        EquipmentTemplate(
            name: "Grapnel Launcher",
            category: EquipmentCategories.tools,
            description: "This set combines a Climbing Harness (see page 146) with a pistol-like launcher that fires a magnetic hook on a line. Once the hook adheres to a wall or other spot, the grapnel's motor lifts the user plus one other person to the top for a rapid ascent.\nThe Grapnel Launcher can reach 50 metres and, once affixed, can lift two Medium-sized creatures or objects at a rate of 5 metres per round. Using the Grapnel Launcher is an Action, and requires an Routine (+20) Ranged (Pistols) Test.",
            encumbrance: 2,
            cost: 1000,
            availability: AvailabilityLevels.rare
        ),
        EquipmentTemplate(
            name: "Grav Chute",
            category: EquipmentCategories.tools,
            description: "Often used by elite Astra Militarum units as part of airborne assaults, these items are worn around the torso and use small anti-grav units to allow for a relatively safe descent. They are not powerful enough to allow hovering or ascension.\nWhile active, a Grav Chute allows a Medium-sized creature to ignore falling damage (see page 203) for 10 minutes. After that time the chute must be recharged, which requires 10 hours connected into a standard Imperial power supply.",
            encumbrance: 2,
            cost: 2000,
            availability: AvailabilityLevels.rare
        ),
        EquipmentTemplate(
            name: "Holy Icon",
            category: EquipmentCategories.tools,
            description: "A Holy Icon might take any number of forms depending on an individual's faith and the specific version of the Imperial Creed they follow. For many it is a small Aquila, perhaps hand-made or gained during a pilgrimage to a sacred location. Icons carved from the ground upon which Saint Macharius trod are popular as well.\nA character with a Holy Icon who has shown sufficient faith may add +1 SL to Discipline (Fear) Tests.",
            encumbrance: 0,
            cost: 10,
            availability: AvailabilityLevels.common
        ),
        EquipmentTemplate(
            name: "Lascutter",
            category: EquipmentCategories.tools,
            description: "Mainly used for cracking apart ore, slicing through voidship bulkheads, and tearing open stubborn doors. Lascutters employ a high-powered, short-range cutting beam that few things can withstand.\nA Lascutter can be used in combination with Tech (Engineering) Tests to cut through solid objects such as bulkheads, vault doors, or walkways.",
            encumbrance: 2,
            cost: 1500,
            availability: AvailabilityLevels.rare
        ),
        EquipmentTemplate(
            name: "Laud Hailer",
            category: EquipmentCategories.tools,
            description: "A Laud Hailer greatly amplifies a person's voice such that they can be heard above crowds of chanting pilgrims, screaming cultists, and hive firefights. They are favourite items for preachers, Enforcers, and others who insist on being heard no matter the situation.\nWhen using a Laud Hailer, your voice or other sounds you play or generate can be easily heard up to 100 metres away.",
            encumbrance: 1,
            cost: 100,
            availability: AvailabilityLevels.common
        ),
        EquipmentTemplate(
            name: "Mag Boots",
            category: EquipmentCategories.tools,
            description: "Mag Boots are commonly part of Void Suits (see page 145) but are also useful on their own when working in pressurised vessels with failed or damaged grav plates.\nAs an Action, you can activate the Magboots to stick to a ferromagnetic surface. This allows you to ignore the effects of zero or low gravity, but your Speed is reduced to Slow. In normal gravity, you can make a Challenging (+0) Athletics (Climbing) or Reflexes (Acrobatics) Test to walk on metallic walls and ceilings. Your Speed is Slow when doing so.",
            encumbrance: 1,
            cost: 200,
            availability: AvailabilityLevels.scarce
        ),
        EquipmentTemplate(
            name: "Magnoculars",
            category: EquipmentCategories.tools,
            description: "Compact and designed for dangerous settings, Magnoculars amplify visual images allowing both Militarum spotters and adepts seeking new fauna species for cataloguing to more easily pick out their targets.\nYou can use Magnoculars in combination with Awareness (Sight) Tests to detect objects at Long Range or further.",
            encumbrance: 0,
            cost: 150,
            availability: AvailabilityLevels.common
        ),
        EquipmentTemplate(
            name: "Manacles",
            category: EquipmentCategories.tools,
            description: "The essential tool of bounty hunters and Enforcers alike, Manacles help ensure a bounty, criminal, or heretic remains helpless and more easily transported to their awaiting fate.\nYou can use an Action to apply Manacles to an unresisting character's wrists or ankles, including those with the Incapacitated, Stunned, or Unconscious Conditions. While they are in place, that target cannot use the bound limbs. Manacles come with keys or a code to lock and unlock the heavy steel cuffs. Otherwise, a Very Hard (−30) Dexterity (Lock Picking), Athletics (Might) or Tech (Security) Test is needed to remove them. This Test is made with Disadvantage if the user is attempting to unlock themself.\nManacles can be destroyed by dealing 10 Damage to them.",
            encumbrance: 1,
            cost: 50,
            availability: AvailabilityLevels.common
        ),
        EquipmentTemplate(
            name: "Micro-Bead/Vox Bead",
            category: EquipmentCategories.tools,
            description: "Designed to fit inside the user's ear, these communication tools let someone effortlessly talk to and hear others on the same vox channel. As their range is far beyond shouting, and work in situations where shouting would call dangerous attention, they are almost essential for mission outfitting.\nThis item allows the wearer to communicate with other users on the same channel within a mile, though dense metallic obstructions and violent weather can lessen or disrupt the ability.",
            encumbrance: 0,
            cost: 80,
            availability: AvailabilityLevels.common
        ),
        EquipmentTemplate(
            name: "Monotask Servo-Skull",
            category: EquipmentCategories.tools,
            description: "Servo-Skulls are the blessed remains of loyal Imperial servants who have been honoured to continue their service to the Emperor even after death. Each Skull is carefully cleaned and anointed, its machine spirit coaxed into action by arcane ritual, and miniature anti grav plates for flight. An attendant Servo-Skull is often a sign of status in the Imperium and especially the Tech-Priesthood; some Macharian leaders have Skulls thought to date back to the Crusade.\n- Additional Rules: A Servo-Skull hovers at roughly eye level and unless instructed otherwise keeps near its assigned user. Each has a specific ability as described below:\n- Iluminator: The Skull has electric candles, burning torches, or other light sources mounted to its form and acts as a glow globe or stablight (see page 148).\n- Laud Hailer: The Servo-Skull has a laud hailer (see page 148) which can amplify pre-recorded sounds or the voice of anyone at Immediate range.\n- Medicae: The Skull is fitted with devices to aid in medical efforts, and grants +10 to Medicae Tests made within Immediate range.\n- Scanner: This Servo-Skull is fitted with an auspex (see page 145) and allows a character at Short range to gain the benefits of that device.\n- Utility: The Servo-Skull has a mix of tools to aid in mechanical tasks, which acts as a Combi-Tool (see page 146) for a character at Immediate range.\nThe Quality of Servo-Skulls can vary the abilities of any implanted devices in the same manner as that device, or can have other effects such as it hovering erratically or drifting away from the characters at times. Greater designs might anticipate their user's needs, be able to carry out simple commands, or subtly move towards possible dangers or heresies through the Omnissiah's Will.",
            encumbrance: 1,
            cost: 2000,
            availability: AvailabilityLevels.rare
        ),
        EquipmentTemplate(
            name: "Multicompass",
            category: EquipmentCategories.tools,
            description: "A valuable device when exploring frontier wilderness, crumbling hivescapes, and other areas lacking directional features, a Multicompass employs a variety of sensors and gyroscopic cogitators to signal axial and magnetic north on a planet.\nYou can use a Multicompass in combination with Navigation (Surface) or other Tests relating to making your way across unfamiliar terrain.",
            encumbrance: 0,
            cost: 100,
            availability: AvailabilityLevels.common
        ),
        EquipmentTemplate(
            name: "Multikey",
            category: EquipmentCategories.tools,
            description: "A Multikey is a very useful, though often highly illegal, tool. As so much Imperial technology is standardised, including most lock technology, each has integrated probes, rakes, and picks specifically designed to defeat most locks a user might encounter.\nYou can use a Multikey in combination with Dexterity (Lock Picking) Tests to bypass locks of Imperial design.",
            encumbrance: 0,
            cost: 200,
            availability: AvailabilityLevels.rare
        ),
        EquipmentTemplate(
            name: "Pict Recorder",
            category: EquipmentCategories.tools,
            description: "Pict Recorders essentially have one use: capturing still pict images and vid scenes. Most can also play the recorded media to the user and are generally lightweight and durable enough to be used in rough climates and rougher taverns. A Pict Recorder can record and store hundreds of images and roughly 10 hours of video.\nOperating a handheld Pict Recorder requires an Action for each round it is in use, but does not require a Test.",
            encumbrance: 0,
            cost: 200,
            availability: AvailabilityLevels.common
        ),
        EquipmentTemplate(
            name: "Psy Focus",
            category: EquipmentCategories.tools,
            description: "These small, simple trinkets might be mistaken for detritus littering a habway, oddly glowing crystals, or elaborately carved icons, but in the hands of a psyker they allow for greater mental clarity when accessing the powers of the Warp. Some might be made personally during training on Terra, others passed down from one rogue psyker to another as a part of joining a cult. All possess a special value their owner might treasure above all else.\nWhen using a Psy Focus, you gain +1 SL to Psychic Mastery Tests. You can not benefit from more than one Psy Focus at a time.",
            encumbrance: 0,
            cost: 500,
            availability: AvailabilityLevels.exotic
        ),
        EquipmentTemplate(
            name: "Screamer",
            category: EquipmentCategories.tools,
            description: "These basic alarm devices set out screeching sonics when a predetermined condition such as movement, sound, or pressure is detected. They can be activated and set as watchdogs against invaders when groups cannot set guard themselves or to supplement their own watch.\nSetting a Screamer requires an Routine (+20) Tech (Security) Test. On a failure, the Screamer immediately goes off and alerts everyone within Long Range. On a success, the Screamer is set and begins to monitor its Zone or an adjacent Zone. Note the SL of the successful Test. When setting the Screamer, the user's can choose for it to monitor for either sound, movement, or pressure.\nWhen a creature enters the Screamer's Zone, they must make a Challenging (+0) Stealth Test to avoid detection, suffering −SL equal to the SL of the Test to set the Screamer. For example, if the Test to set the Screamer succeeded with +3 SL, any Stealth Test to avoid detection would suffer −3 SL. If the Screamer detects a change in the condition chosen, it erupts loudly, alerting everyone within Long Range.",
            encumbrance: 0,
            cost: 150,
            availability: AvailabilityLevels.common
        ),
        EquipmentTemplate(
            name: "Sacred Unguents",
            category: EquipmentCategories.tools,
            description: "These Omnissiah-blessed lubricating oils can calm even the most recalcitrant of Machine Spirits, allowing them to operate with ease and ignore slights against their forms.\nYou can use Sacred Unguents 5 times. As an Action, you can make a Challenging (+0) Tech (Engineering) Test to apply Sacred Unguents to an Imperial technological item, vehicle, or weapon. If you succeed, the next time you fail a Test using the affected item, you re-roll the Test. After this re-roll, or if one day passes, the applied Sacred Unguents dry up and this effect ends. If you fail the Test to apply Sacred Unguents, you incorrectly apply the Unguents, or the machine spirit demands more to be appeased, either way you waste one use of Sacred Unguents.",
            encumbrance: 0,
            cost: 200,
            availability: AvailabilityLevels.rare
        ),
        EquipmentTemplate(
            name: "Signal Jammer",
            category: EquipmentCategories.tools,
            description: "Signal Jammers overload airborne electronic transmissions such as vox messages and data feeds, completely severing the connection. There is usually no attempt at subtlety and everyone with access to the transmissions can tell something is interfering, but if simple ceasing of communication is the goal, then Signal Jammers do the job quite well.\nYou can activate the Signal Jammer as a Free Action. While active, the Signal Jammer disrupts vox and data transmissions within 1 kilometre. If not connected to a power source, a jammer can operate for 2 hours before its battery is depleted.",
            encumbrance: 1,
            cost: 500,
            availability: AvailabilityLevels.rare
        ),
        EquipmentTemplate(
            name: "Stummer",
            category: EquipmentCategories.tools,
            description: "Stummers cancel ambient noise through integral cogitators using sonic sensors and waveform dampeners. They are quite useful for covert operations but as they cancel all sound this means team members must rely on non-verbal communication.\nWhen activated as a Free Action, a Stummer increases the Difficulty of sonic Awareness Tests made to detect unexpected sounds in the same Zone by three steps.\nIts power lasts for 20 minutes; recharging takes several minutes once connected to a standard Imperial power source. Multiple Stummer effects do not stack.",
            encumbrance: 1,
            cost: 1000,
            availability: AvailabilityLevels.rare
        ),
        EquipmentTemplate(
            name: "Vox-Caster",
            category: EquipmentCategories.tools,
            description: "This is the standard Imperial communication device, based on especially reliable STC patterns, used across the galaxy for untold centuries. A Vox-Caster allows messages to be sent over long distances, even reaching vessels in low orbit.\nA Vox-Caster allows voice transmission to other Vox- Casters and small units, such as Vox Beads, within 100 kilometres.",
            encumbrance: 2,
            cost: 300,
            availability: AvailabilityLevels.common
        ),
        EquipmentTemplate(
            name: "Writing Kit",
            category: EquipmentCategories.tools,
            description: "These basic kits are ideal in areas where technology is unavailable or unreliable. Each kit contains parchment, ink, quills, and other writing implements.",
            encumbrance: 0,
            cost: 25,
            availability: AvailabilityLevels.common
        )
    ]
    
    // MARK: - Augmetics (placeholder - can be expanded later)
    static let augmetics: [EquipmentTemplate] = [
        // Placeholder for future augmetic templates
    ]
    
    static let allEquipment: [EquipmentTemplate] = forceFields + clothingPersonalGear + tools + augmetics
    
    static func getTemplate(for name: String) -> EquipmentTemplate? {
        return allEquipment.first { $0.name.lowercased() == name.lowercased() }
    }
    
    static func getEquipmentByCategory(_ category: String) -> [EquipmentTemplate] {
        return allEquipment.filter { $0.category == category }
    }
    
    static func getCategoryForEquipment(_ equipmentName: String) -> String {
        if let template = getTemplate(for: equipmentName) {
            return template.category
        }
        return "Other"
    }
}
