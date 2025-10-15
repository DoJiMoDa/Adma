# Main.gd
extends Control

# Player resources
var gold: int = 1000
var reputation: int = 0  # 0-500 scale

# Recruitment pool
var available_adventurers: Array = []

# Party management
var parties: Array = []  # Array of party dictionaries
var max_party_size: int = 5
var next_party_id: int = 1

# Scene references
@export var card_scene: PackedScene
@export var party_card_scene: PackedScene

# UI References - Top Bar
@onready var gold_label: Label = %GoldLabel
@onready var reputation_label = %ReputationLabel

# UI References - Tabs
@onready var quests_tab: Button = %QuestsTab
@onready var guild_tab = %GuildTab
@onready var recruitment_tab = %RecruitmentTab
@onready var equipment_tab = %EquipmentTab

# UI References - Content Panels
@onready var quests_panel = %QuestsPanel
@onready var guild_panel = %GuildPanel
@onready var recruitment_panel = %RecruitmentPanel
@onready var equipment_panel = %EquipmentPanel

# UI References - Recruitment (inside RecruitmentPanel)
@onready var recruitment_list = %RecruitmentList
@onready var refresh_button = %Refresh
@onready var parties_list = %PartiesList

func _ready():
	# Randomize reputation at start
	randomize()
	reputation = randi() % 501  # 0-500
	
	update_ui()
	
	# Set starting tab (Quests)
	show_tab("quests")
	quests_tab.button_pressed = true

func update_ui():
	gold_label.text = "Gold: %d" % gold
	var rep_type = get_reputation_type()
	reputation_label.text = "Reputation: %d (%s)" % [reputation, rep_type]

# ===== TAB SYSTEM =====

func show_tab(tab_name: String):
	# Hide all panels
	quests_panel.visible = false
	guild_panel.visible = false
	recruitment_panel.visible = false
	equipment_panel.visible = false
	
	# Show selected panel and highlight tab
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
	show_tab("equipment")

# ===== PARTY SYSTEM =====

func get_reputation_type() -> String:
	if reputation <= 175:
		return "Evil"
	elif reputation <= 325:
		return "Neutral"
	else:
		return "Good"

func create_new_party(party_name: String) -> Dictionary:
	var party = {
		"id": next_party_id,
		"name": party_name,
		"members": []
	}
	next_party_id += 1
	parties.append(party)
	return party

func get_available_party() -> Dictionary:
	# Find first party with space
	for party in parties:
		if party.members.size() < max_party_size:
			return party
	
	# If all parties are full, create a new one with placeholder name
	var new_party = create_new_party("New Party")
	return new_party

func add_adventurer_to_party(adventurer: Dictionary):
	var party = get_available_party()
	
	# If this is the first member, name the party after them
	if party.members.size() == 0:
		party.name = "Team %s" % adventurer.name
	
	party.members.append(adventurer)
	print("Added %s to %s (now %d/%d members)" % [adventurer.name, party.name, party.members.size(), max_party_size])
	update_parties_display()

# ===== RECRUITMENT SYSTEM =====

func get_recruitment_pool_size() -> int:
	# At 250 (center) = 5, at extremes (0 or 500) = 10
	var distance_from_center = abs(reputation - 250)
	# Map 0-250 distance to 5-10 range
	var pool_size = 5 + int((distance_from_center / 250.0) * 5)
	return pool_size

func refresh_recruitment_pool():
	# Clear existing adventurers
	for child in recruitment_list.get_children():
		child.queue_free()
	
	available_adventurers.clear()
	
	var pool_size = get_recruitment_pool_size()
	var rep_type = get_reputation_type()
	
	# Generate adventurers with alignment bias
	for i in range(pool_size):
		var adventurer = generate_adventurer_with_bias(rep_type)
		available_adventurers.append(adventurer)
		create_adventurer_card(adventurer)

func generate_adventurer_with_bias(player_alignment: String) -> Dictionary:
	var adventurer_class = get_random_class_with_bias(player_alignment)
	
	return {
		"name": generate_random_name(),
		"class": adventurer_class,
		"level": 1,
		"stats": generate_stats(adventurer_class),
		"alignment": AdventurerData.CLASS_ALIGNMENTS[adventurer_class],
		"cost": calculate_hire_cost(adventurer_class)
	}

func get_random_class_with_bias(player_alignment: String) -> String:
	var classes = AdventurerData.CLASSES.duplicate()
	var weighted_classes = []
	
	# Create weighted list based on alignment match
	for adventurer_class in classes:
		var class_alignment = AdventurerData.CLASS_ALIGNMENTS[adventurer_class]
		
		# Add class multiple times based on alignment match
		if class_alignment == player_alignment:
			# 50% chance for matching alignment
			for j in range(5):
				weighted_classes.append(adventurer_class)
		elif class_alignment == "Neutral" or player_alignment == "Neutral":
			# 30% chance for neutral
			for j in range(3):
				weighted_classes.append(adventurer_class)
		else:
			# 20% chance for opposite alignment
			weighted_classes.append(adventurer_class)
	
	return weighted_classes[randi() % weighted_classes.size()]

func generate_stats(adventurer_class: String) -> Dictionary:
	var base_stats = {
		"STR": roll_stat(),
		"DEX": roll_stat(),
		"CON": roll_stat(),
		"INT": roll_stat(),
		"WIS": roll_stat(),
		"CHA": roll_stat()
	}
	
	# Apply class bonuses
	var bonuses = AdventurerData.CLASS_STAT_BONUSES.get(adventurer_class, {})
	for stat in bonuses:
		base_stats[stat] = min(18, base_stats[stat] + bonuses[stat])
	
	return base_stats

func roll_stat() -> int:
	# Roll 3d6 for D&D style stats (3-18)
	return (randi() % 6 + 1) + (randi() % 6 + 1) + (randi() % 6 + 1)

func calculate_hire_cost(adventurer_class: String) -> int:
	var base_cost = AdventurerData.CLASS_BASE_COSTS[adventurer_class]
	var class_alignment = AdventurerData.CLASS_ALIGNMENTS[adventurer_class]
	var player_alignment = get_reputation_type()
	
	var modifier = 1.0
	
	if class_alignment == player_alignment:
		modifier = 0.8  # -20% for matching alignment
	elif class_alignment == "Neutral" or player_alignment == "Neutral":
		modifier = 1.0  # No change for neutral
	else:
		modifier = 1.5  # +50% for opposite alignment
	
	return int(base_cost * modifier)

func generate_random_name() -> String:
	var first_names = ["Aldric", "Brianna", "Cedric", "Diana", "Eren", "Fiona", 
					   "Gareth", "Helena", "Ivan", "Jade", "Kael", "Luna",
					   "Marcus", "Nora", "Owen", "Petra", "Quinn", "Raven",
					   "Silas", "Thora", "Uther", "Vera", "Wesley", "Xara",
					   "Yorick", "Zara"]
	
	return first_names[randi() % first_names.size()]

func create_adventurer_card(adventurer: Dictionary):
	var card = card_scene.instantiate()
	
	# Add to scene first to avoid null references
	recruitment_list.add_child(card)
	
	# Set card data
	card.heroname.text = "%s - Lvl %d %s" % [adventurer.name, adventurer.level, adventurer.class]
	card.alignment.text = "Alignment: %s" % adventurer.alignment
	card.stats.text = "STR:%d DEX:%d CON:%d INT:%d WIS:%d CHA:%d" % [
		adventurer.stats.STR, adventurer.stats.DEX, adventurer.stats.CON,
		adventurer.stats.INT, adventurer.stats.WIS, adventurer.stats.CHA
	]
	card.cost.text = "%d gold" % adventurer.cost
	
	# Connect hire button
	card.button.pressed.connect(_on_hire_adventurer.bind(adventurer, card))

func _on_hire_adventurer(adventurer: Dictionary, card: Control):
	if gold >= adventurer.cost:
		gold -= adventurer.cost
		
		# Add to party
		add_adventurer_to_party(adventurer)
		
		# Remove from recruitment pool
		available_adventurers.erase(adventurer)
		card.queue_free()
		
		update_ui()
		print("Hired %s the %s for %d gold!" % [adventurer.name, adventurer.class, adventurer.cost])
	else:
		print("Not enough gold!")

func _on_refresh_pressed():
	refresh_recruitment_pool()

func update_parties_display():
	# Clear existing party displays
	for child in parties_list.get_children():
		child.queue_free()
	
	# Create display for each party
	for party in parties:
		var party_card = party_card_scene.instantiate()
		
		# Add to scene first
		parties_list.add_child(party_card)
		
		# Set party name
		party_card.get_node("%PartyName").text = "%s (%d/%d)" % [party.name, party.members.size(), max_party_size]
		
		# Get the member container
		var member_container = party_card.get_node("%PartiesContainer")
		
		# Clear any existing members in the card template
		for child in member_container.get_children():
			child.queue_free()
		
		# Add party members
		if party.members.size() > 0:
			for member in party.members:
				var memberscene = load("res://party_member.tscn")
				var membercontainer = memberscene.instantiate()
				member_container.add_child(membercontainer)
				
				# Set member data
				membercontainer.get_node("%HeroName").text = member.name
				membercontainer.get_node("%HeroClass").text = member.class
				membercontainer.get_node("%HeroLevel").text = "Lvl %d" % member.level
				
				# Set class icon
				var class_icon = get_class_icon(member.class)
				if class_icon:
					membercontainer.get_node("CenterContainer/TextureRect").texture = class_icon
				
		else:
			# Show empty slots
			for i in range(max_party_size):
				var memberscene = load("res://party_member.tscn")
				var membercontainer = memberscene.instantiate()
				member_container.add_child(membercontainer)
				
				membercontainer.get_node("%HeroName").text = "Empty"
				membercontainer.get_node("%HeroClass").text = ""
				membercontainer.get_node("%HeroLevel").text = ""
				membercontainer.modulate = Color(0.5, 0.5, 0.5, 0.5)

func get_class_icon(HeroClass_name: String) -> Texture2D:
	# Map class names to icon paths
	var icon_path = AdventurerData.CLASS_ICONS.get(HeroClass_name, "")
	if icon_path != "" and ResourceLoader.exists(icon_path):
		return load(icon_path)
	return null

func _on_button_pressed() -> void:
	update_ui()
	update_parties_display()
