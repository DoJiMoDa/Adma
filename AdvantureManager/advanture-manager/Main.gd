# Main.gd (Super Clean Version)
extends Control

# Managers (created as children)
var recruitment_manager: Node
var party_manager: Node
var equipment_manager: Node

# UI References - Top Bar
@onready var gold_label: Label = %GoldLabel
@onready var reputation_label: Label = %ReputationLabel

# UI References - Tabs
@onready var quests_tab: Button = %QuestsTab
@onready var guild_tab: Button = %GuildTab
@onready var recruitment_tab: Button = %RecruitmentTab
@onready var equipment_tab: Button = %EquipmentTab

# UI References - Content Panels
@onready var quests_panel = %QuestsPanel
@onready var guild_panel = %GuildPanel
@onready var recruitment_panel = %RecruitmentPanel
@onready var equipment_panel = %EquipmentPanel

func _ready():
	# Connect to GameManager signals for top bar
	GameManager.gold_changed.connect(_on_gold_changed)
	GameManager.reputation_changed.connect(_on_reputation_changed)
	
	# Connect tab buttons
	quests_tab.pressed.connect(_on_quests_tab_pressed)
	guild_tab.pressed.connect(_on_guild_tab_pressed)
	recruitment_tab.pressed.connect(_on_recruitment_tab_pressed)
	equipment_tab.pressed.connect(_on_equipment_tab_pressed)
	
	# Initial UI update
	update_top_bar()
	
	# Set starting tab
	show_tab("quests")
	quests_tab.button_pressed = true

# ===== TOP BAR UI =====

func update_top_bar():
	gold_label.text = "Gold: %d" % GameManager.gold
	reputation_label.text = "Reputation: %d (%s)" % [GameManager.reputation, GameManager.get_reputation_type()]

func _on_gold_changed(new_amount: int):
	gold_label.text = "Gold: %d" % new_amount

func _on_reputation_changed(new_amount: int, rep_type: String):
	reputation_label.text = "Reputation: %d (%s)" % [new_amount, rep_type]

# ===== TAB SYSTEM =====

func show_tab(tab_name: String):
	# Hide all panels
	quests_panel.visible = false
	guild_panel.visible = false
	recruitment_panel.visible = false
	equipment_panel.visible = false
	
	# Show selected panel
	match tab_name:
		"quests":
			quests_panel.visible = true
		"guild":
			guild_panel.visible = true
		"recruitment":
			recruitment_panel.visible = true
		"equipment":
			equipment_panel.visible = true

func _on_quests_tab_pressed():
	show_tab("quests")

func _on_guild_tab_pressed():
	show_tab("guild")

func _on_recruitment_tab_pressed():
	show_tab("recruitment")

func _on_equipment_tab_pressed():
	equipment_panel.refresh()
	show_tab("equipment")

func _on_refresh_pressed() -> void:
	recruitment_panel.refreshpool()
