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
