# AdventurerData.gd
# This should be an autoload singleton
# Project -> Project Settings -> Autoload -> Add this script as "AdventurerData"

extends Node

# All available classes
const CLASSES = [
	"Warrior", "Ranger", "Bard",  # Neutral
	"Thief", "Assassin", "Warlock", "Rogue",  # Evil
	"Paladin", "Cleric", "Monk", "Mage"  # Good/Neutral
]

# Class alignments
const CLASS_ALIGNMENTS = {
	"Warrior": "Neutral",
	"Ranger": "Neutral",
	"Bard": "Neutral",
	"Mage": "Neutral",
	"Thief": "Evil",
	"Assassin": "Evil",
	"Warlock": "Evil",
	"Rogue": "Evil",
	"Paladin": "Good",
	"Cleric": "Good",
	"Monk": "Good"
}

# Base hiring costs
const CLASS_BASE_COSTS = {
	"Warrior": 100,
	"Ranger": 100,
	"Bard": 100,
	"Mage": 100,
	"Thief": 100,
	"Assassin": 150,
	"Warlock": 150,
	"Rogue": 100,
	"Paladin": 150,
	"Cleric": 150,
	"Monk": 150
}

# Stat bonuses by class
const CLASS_STAT_BONUSES = {
	"Warrior": {"STR": 2, "CON": 1},
	"Ranger": {"DEX": 2, "WIS": 1},
	"Bard": {"CHA": 2, "DEX": 1},
	"Mage": {"INT": 2, "WIS": 1},
	"Thief": {"DEX": 2, "CHA": 1},
	"Assassin": {"DEX": 2, "STR": 1},
	"Warlock": {"INT": 2, "CHA": 1},
	"Rogue": {"DEX": 2, "INT": 1},
	"Paladin": {"STR": 2, "CHA": 1},
	"Cleric": {"WIS": 2, "CON": 1},
	"Monk": {"DEX": 1, "WIS": 2}
}

# Class icons - Update these paths to match your icon locations
const CLASS_ICONS = {
	"Warrior": "res://Icons/ClassIcons/Adma_Warrior.png",
	"Ranger": "res://Icons/ClassIcons/Adma_Ranger.png",
	"Bard": "res://Icons/ClassIcons/Adma_bard.png",
	"Mage": "res://Icons/ClassIcons/Adma_Mage.png",
	"Thief": "res://Icons/ClassIcons/Adma_Thief.png",
	"Assassin": "res://Icons/ClassIcons/Adma_Assassin.png",
	"Warlock": "res://Icons/ClassIcons/Adma_Warlock.png",
	"Rogue": "res://Icons/ClassIcons/Adma_Rogue.png",
	"Paladin": "res://Icons/ClassIcons/Adma_Paladin.png",
	"Cleric": "res://Icons/ClassIcons/Adma_Cleric.png",
	"Monk": "res://Icons/ClassIcons/Adma_Monk.png"
}

# Equipment slot types
enum EquipmentSlot {
	MAIN_HAND,
	OFF_HAND,
	HELMET,
	ARMOR,
	TRINKET_1,
	TRINKET_2
}

# Equipment rarities
enum Rarity {
	COMMON,
	UNCOMMON,
	RARE,
	EPIC,
	LEGENDARY
}

# Equipment types
enum ItemType {
	WEAPON,
	SHIELD,
	HELMET,
	ARMOR,
	RING,
	AMULET
}

static var equipment={
		"main_hand": null,
		"off_hand": null,
		"helmet": null,
		"armor": null,
		"trinket_1": null,
		"trinket_2": null
}

# Helper function to create empty equipment
static func create_empty_equipment() -> Dictionary:
	equipment= {
		"main_hand": null,
		"off_hand": null,
		"helmet": null,
		"armor": null,
		"trinket_1": null,
		"trinket_2": null
	}
	return equipment

# Helper function to create an item
static func create_item(item_name: String, item_type: int, rarity: int, stats: Dictionary, cost: int) -> Dictionary:
	return {
		"name": item_name,
		"type": item_type,
		"rarity": rarity,
		"stats": stats,  # Dictionary like {"STR": 2, "DEX": 1}
		"cost": cost
	}

# Sample items database (you'll expand this)
const SAMPLE_ITEMS = {
	# Weapons
	"Iron Sword": {
		"type": ItemType.WEAPON,
		"slot": EquipmentSlot.MAIN_HAND,
		"rarity": Rarity.COMMON,
		"stats": {"STR": 2},
		"cost": 50
	},
	"Steel Sword": {
		"type": ItemType.WEAPON,
		"slot": EquipmentSlot.MAIN_HAND,
		"rarity": Rarity.UNCOMMON,
		"stats": {"STR": 3, "DEX": 1},
		"cost": 150
	},
	"Legendary Blade": {
		"type": ItemType.WEAPON,
		"slot": EquipmentSlot.MAIN_HAND,
		"rarity": Rarity.LEGENDARY,
		"stats": {"STR": 5, "DEX": 3, "CON": 2},
		"cost": 1000
	},

	# Shields
	"Wooden Shield": {
		"type": ItemType.SHIELD,
		"slot": EquipmentSlot.OFF_HAND,
		"rarity": Rarity.COMMON,
		"stats": {"CON": 1},
		"cost": 30
	},
	"Steel Shield": {
		"type": ItemType.SHIELD,
		"slot": EquipmentSlot.OFF_HAND,
		"rarity": Rarity.UNCOMMON,
		"stats": {"CON": 2, "STR": 1},
		"cost": 120
	},

	# Helmets
	"Leather Cap": {
		"type": ItemType.HELMET,
		"slot": EquipmentSlot.HELMET,
		"rarity": Rarity.COMMON,
		"stats": {"CON": 1},
		"cost": 40
	},
	"Iron Helmet": {
		"type": ItemType.HELMET,
		"slot": EquipmentSlot.HELMET,
		"rarity": Rarity.UNCOMMON,
		"stats": {"CON": 2, "WIS": 1},
		"cost": 100
	},

	# Armor
	"Leather Armor": {
		"type": ItemType.ARMOR,
		"slot": EquipmentSlot.ARMOR,
		"rarity": Rarity.COMMON,
		"stats": {"CON": 2, "DEX": 1},
		"cost": 80
	},
	"Chainmail": {
		"type": ItemType.ARMOR,
		"slot": EquipmentSlot.ARMOR,
		"rarity": Rarity.UNCOMMON,
		"stats": {"CON": 3, "STR": 1},
		"cost": 200
	},
	"Plate Armor": {
		"type": ItemType.ARMOR,
		"slot": EquipmentSlot.ARMOR,
		"rarity": Rarity.RARE,
		"stats": {"CON": 5, "STR": 2},
		"cost": 500
	},

	# Rings/Trinkets
	"Ring of Strength": {
		"type": ItemType.RING,
		"slot": EquipmentSlot.TRINKET_1,
		"rarity": Rarity.UNCOMMON,
		"stats": {"STR": 2},
		"cost": 150
	},
	"Ring of Wisdom": {
		"type": ItemType.RING,
		"slot": EquipmentSlot.TRINKET_2,
		"rarity": Rarity.UNCOMMON,
		"stats": {"WIS": 2},
		"cost": 150
	},
	"Amulet of Health": {
		"type": ItemType.AMULET,
		"slot": EquipmentSlot.TRINKET_1,  # or TRINKET_2 if you prefer variety
		"rarity": Rarity.RARE,
		"stats": {"CON": 3},
		"cost": 300
	}
}


# Get rarity color
static func get_rarity_color(rarity: int) -> Color:
	match rarity:
		Rarity.COMMON:
			return Color.GRAY
		Rarity.UNCOMMON:
			return Color.GREEN
		Rarity.RARE:
			return Color.BLUE
		Rarity.EPIC:
			return Color.PURPLE
		Rarity.LEGENDARY:
			return Color.ORANGE
	return Color.WHITE

# Get rarity name
static func get_rarity_name(rarity: int) -> String:
	match rarity:
		Rarity.COMMON:
			return "Common"
		Rarity.UNCOMMON:
			return "Uncommon"
		Rarity.RARE:
			return "Rare"
		Rarity.EPIC:
			return "Epic"
		Rarity.LEGENDARY:
			return "Legendary"
	return "Unknown"
	
static func equip_item(member,item):
	if not "equipment" in member:
		member.equipment=create_empty_equipment()
	match item["type"]: 
		EquipmentSlot.MAIN_HAND:
			member.equipment["main_hand"]=item
		EquipmentSlot.OFF_HAND:
			member.equipment["off_hand"]=item
		EquipmentSlot.HELMET:
			member.equipment["helmet"]=item
		EquipmentSlot.ARMOR:
			member.equipment["armor"]=item
		EquipmentSlot.TRINKET_1:
			member.equipment["trinket_1"]=item
		EquipmentSlot.TRINKET_2:
			member.equipment["trinket_2"]=item
