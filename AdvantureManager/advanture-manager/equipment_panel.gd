# EquipmentManager.gd
extends ColorRect

@export var itemcard: PackedScene
# Shop
var shop_items: Array = []
var selected_adventurer: Dictionary = {}

# Signals
signal shop_refreshed(items: Array)
signal item_purchased(item: Dictionary)
signal item_equipped(adventurer: Dictionary, item: Dictionary, slot: String)

@onready var shop_items_list: VBoxContainer = %ShopItemsList
@onready var advanturer_selector: OptionButton = %AdvanturerSelector
@onready var main_hand_item: Label = %MainHandItem
@onready var off_hand_item: Label = %OffHandItem
@onready var helmet_item: Label = %HelmetItem
@onready var armor_item: Label = %ArmorItem
@onready var trinket_1_item: Label = %Trinket1Item
@onready var trinket_2_item: Label = %Trinket2Item
@onready var player_items: VBoxContainer = %PlayerItems

@onready var stats_display: Label = %StatsDisplay

# ===== SHOP SYSTEM =====

func create_shop_items():
	for child in shop_items_list.get_children():
		child.queue_free()
	shop_items.clear()
	
	# Generate 5-10 random items
	var item_count = randi() % 6 + 5
	var item_names = AdventurerData.SAMPLE_ITEMS.keys()	
	for i in range(item_count):
		var random_item_name = item_names[randi() % item_names.size()]
		var item_data = AdventurerData.SAMPLE_ITEMS[random_item_name].duplicate()
		item_data["name"] = random_item_name
		shop_items.append(item_data)
		var card=itemcard.instantiate()
		shop_items_list.add_child(card)
		card.buy_button.pressed.connect(purchase_item.bind(item_data,card))
		card.item_name_label.text=item_data.name
		card.item_rarity_label.text=str(item_data.rarity)
		var stats_text = ""
		for stat in item_data.stats:
			if stats_text != "":
				stats_text += ", "
			stats_text += "%s +%d" % [stat, item_data.stats[stat]]
		card.item_stats_label.text = stats_text
			
		card.item_cost_label.text = "%d gold" % item_data.cost
		
		#buy_button:
		emit_signal("shop_refreshed", shop_items)

func refresh():
	advanturer_selector.clear()
	for party:Party in PartyManager.get_all_parties():
		for index in range(PartyManager.max_party_size):
			var member= party.getadventurer(index)
			if member:
				print(member)
				advanturer_selector.add_item(member["name"])
	if advanturer_selector.item_count>0:
		advanturer_selector.select(0)
		selected_adventurer=PartyManager.get_all_parties()[0].getadventurer(0)
		update_equipment_display()
func get_shop_items() -> Array:
	return shop_items

func purchase_item(item: Dictionary,current_itemcard:Control) -> bool:
	if GameManager.remove_gold(item.cost):
		GameManager.add_item_to_inventory(item.duplicate())
		shop_items.erase(item)
		
		var card = current_itemcard.duplicate()
		player_items.add_child(card)
		card.buy_button.text = "equip"
		card.buy_button.pressed.connect(equip_item_to_adventurer.bind(selected_adventurer,item))
		emit_signal("item_purchased", item)
		print("Purchased %s for %d gold!" % [item.name, item.cost])
		return true
	else:
		print("Not enough gold!")
		return false

# ===== EQUIPMENT MANAGEMENT =====

func equip_item_to_adventurer(adventurer: Dictionary, item: Dictionary) -> bool:
	if adventurer.is_empty():
		return false
	
	# Use AdventurerData's equip function
	AdventurerData.equip_item(adventurer, item)
	
	# Remove from player inventory
	GameManager.remove_item_from_inventory(item)
	
	emit_signal("item_equipped", adventurer, item, "")
	return true

func unequip_item(adventurer: Dictionary, slot: String) -> Dictionary:
	if not adventurer.has("equipment") or not adventurer.equipment.has(slot):
		return {}
	
	var item = adventurer.equipment[slot]
	if item != null:
		adventurer.equipment[slot] = null
		GameManager.add_item_to_inventory(item)
		return item
	
	return {}

# ===== STAT CALCULATIONS =====

func get_adventurer_total_stats(adventurer: Dictionary) -> Dictionary:
	var equipment_stats = {}
	
	# Start with base stats
	for stat in adventurer["stats"]:
		equipment_stats[stat] = adventurer["stats"][stat]
	
	# Add equipment bonuses
	var equipment_slots = ["main_hand", "off_hand", "helmet", "armor", "trinket_1", "trinket_2"]
	for slot in equipment_slots:
		add_equipment_slot_stats(adventurer, slot, equipment_stats)
	
	return equipment_stats

func add_equipment_slot_stats(adventurer: Dictionary, slot: String, stats_dict: Dictionary):
	if not "equipment" in adventurer: 
		return
	if adventurer["equipment"][slot] == null:
		return
	
	var item = adventurer["equipment"][slot]
	if item.has("stats"):
		for stat in item["stats"]:
			if stat not in stats_dict:
				stats_dict[stat] = 0
			stats_dict[stat] += item["stats"][stat]

func get_item_display_name(item) -> String:
	if item == null:
		return "(Empty)"
	return item.name if item.has("name") else "(Unknown)"

# ===== SELECTED ADVENTURER =====

func set_selected_adventurer(adventurer: Dictionary):
	selected_adventurer = adventurer

func get_selected_adventurer() -> Dictionary:
	return selected_adventurer
	
func update_equipment_display():
	if selected_adventurer.is_empty():
		return
		# Update stats display
	var total_stats = get_adventurer_total_stats(selected_adventurer)
	var stats_text = "Total Stats:\n"
	for stat in ["STR", "DEX", "CON", "INT", "WIS", "CHA"]:
		if total_stats.has(stat):
			var base_stat = selected_adventurer.stats[stat]
			var bonus = total_stats[stat] - base_stat
			if bonus > 0:
				stats_text += "%s: %d (+%d)\n" % [stat, total_stats[stat], bonus]
			else:
				stats_text += "%s: %d\n" % [stat, total_stats[stat]]
	
	stats_display.text = stats_text

	if not "equipment" in selected_adventurer:
		return
		# Update equipment slots
	main_hand_item.text = get_item_display_name(selected_adventurer.equipment.main_hand)
	off_hand_item.text = get_item_display_name(selected_adventurer.equipment.off_hand)
	helmet_item.text = get_item_display_name(selected_adventurer.equipment.helmet)
	armor_item.text = get_item_display_name(selected_adventurer.equipment.armor)
	trinket_1_item.text = get_item_display_name(selected_adventurer.equipment.trinket_1)
	trinket_2_item.text = get_item_display_name(selected_adventurer.equipment.trinket_2)
