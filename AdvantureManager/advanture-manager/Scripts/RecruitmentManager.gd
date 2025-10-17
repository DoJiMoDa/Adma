extends Node

signal recruitment_pool_refreshed

signal adventurer_hired
var adventurers=[]
var available_adventurers=[]

func hire_adventurer(adventurer):
	adventurers.append(adventurer)
	adventurer_hired.emit(adventurer)
	return true

func refresh_recruitment_pool():
	# Clear existing adventurers
#	for child in recruitment_list.get_children():
#		child.queue_free()
	
	available_adventurers.clear()
	
	var pool_size = get_recruitment_pool_size()
	var rep_type = get_reputation_type()
	
	# Generate adventurers with alignment bias
	for i in range(pool_size):
		var adventurer = generate_adventurer_with_bias(rep_type)
		available_adventurers.append(adventurer)
	recruitment_pool_refreshed.emit(available_adventurers)

func get_recruitment_pool_size() -> int:
	# At 250 (center) = 5, at extremes (0 or 500) = 10
	var distance_from_center = abs(GameManager.reputation - 250)
	# Map 0-250 distance to 5-10 range
	var pool_size = 5 + int((distance_from_center / 250.0) * 5)
	return pool_size

func get_reputation_type() -> String:
	if GameManager.reputation <= 175:
		return "Evil"
	elif GameManager.reputation <= 325:
		return "Neutral"
	else:
		return "Good"

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

func generate_random_name() -> String:
	var first_names = ["Aldric", "Brianna", "Cedric", "Diana", "Eren", "Fiona", 
					   "Gareth", "Helena", "Ivan", "Jade", "Kael", "Luna",
					   "Marcus", "Nora", "Owen", "Petra", "Quinn", "Raven",
					   "Silas", "Thora", "Uther", "Vera", "Wesley", "Xara",
					   "Yorick", "Zara"]
	
	return first_names[randi() % first_names.size()]
	
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
