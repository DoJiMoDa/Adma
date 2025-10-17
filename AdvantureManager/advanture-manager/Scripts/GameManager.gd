# GameManager.gd
# Autoload Singleton - Add to Project Settings -> Autoload as "GameManager"
extends Node

# Player resources
var gold: int = 1000
var reputation: int = 0  # 0-500 scale
var player_inventory: Array = []  # Items owned by player

# Signals for UI updates
signal gold_changed(new_amount: int)
signal reputation_changed(new_amount: int, type: String)
signal inventory_changed()

func _ready():
	# Randomize reputation at start
	randomize()
	reputation = randi() % 501  # 0-500
	emit_signal("reputation_changed", reputation, get_reputation_type())

# ===== GOLD MANAGEMENT =====

func add_gold(amount: int):
	gold += amount
	emit_signal("gold_changed", gold)

func remove_gold(amount: int) -> bool:
	if gold >= amount:
		gold -= amount
		emit_signal("gold_changed", gold)
		return true
	return false

func has_gold(amount: int) -> bool:
	return gold >= amount

# ===== REPUTATION MANAGEMENT =====

func add_reputation(amount: int):
	reputation = clamp(reputation + amount, 0, 500)
	emit_signal("reputation_changed", reputation, get_reputation_type())

func remove_reputation(amount: int):
	reputation = clamp(reputation - amount, 0, 500)
	emit_signal("reputation_changed", reputation, get_reputation_type())

func get_reputation_type() -> String:
	if reputation <= 175:
		return "Evil"
	elif reputation <= 325:
		return "Neutral"
	else:
		return "Good"

# ===== INVENTORY MANAGEMENT =====

func add_item_to_inventory(item: Dictionary):
	player_inventory.append(item.duplicate())
	emit_signal("inventory_changed")

func remove_item_from_inventory(item: Dictionary) -> bool:
	if player_inventory.has(item):
		player_inventory.erase(item)
		emit_signal("inventory_changed")
		return true
	return false

func get_inventory() -> Array:
	return player_inventory
