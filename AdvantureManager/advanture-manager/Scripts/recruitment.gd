# RecruitmentUI.gd
# Attach this to the RecruitmentPanel node
extends ColorRect

# Scene references
@export var card_scene: PackedScene
@export var party_card_scene: PackedScene
# UI References
@onready var recruitment_list: VBoxContainer = %RecruitmentList
@onready var parties_list: VBoxContainer = %PartiesList
@onready var refresh_button: Button = %Refresh

func _ready():
	
	# Connect signals
	refresh_button.pressed.connect(_on_refresh_pressed)
	RecruitmentManager.recruitment_pool_refreshed.connect(_on_recruitment_pool_refreshed)
	RecruitmentManager.adventurer_hired.connect(_on_adventurer_hired)
	PartyManager.onpartyupdated.connect(_on_party_updated)

func _on_refresh_pressed():
	RecruitmentManager.refresh_recruitment_pool()

func _on_recruitment_pool_refreshed(adventurers: Array):
	# Clear existing cards
	for child in recruitment_list.get_children():
		child.queue_free()
	
	# Create new cards
	for adventurer in adventurers:
		create_adventurer_card(adventurer)

func create_adventurer_card(adventurer: Dictionary):
	var card = card_scene.instantiate()
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
	if GameManager.gold>=adventurer.cost and RecruitmentManager.hire_adventurer(adventurer):
		PartyManager.add_adventurer_to_party(adventurer)
		card.queue_free()

func _on_adventurer_hired(adventurer: Dictionary):
	print("Hired %s the %s!" % [adventurer.name, adventurer.class])
	GameManager.add_gold(-adventurer.cost)
func _on_party_updated(party: Party):
	update_parties_display()

func update_parties_display():
	for child in parties_list.get_children():
		child.queue_free()
	
	for party in PartyManager.get_all_parties():
		create_party_card(party)

func create_party_card(party: Party):
	var party_card = party_card_scene.instantiate()
	parties_list.add_child(party_card)
	
	party_card.get_node("%PartyName").text = "%s (%d/%d)" % [party.name, party.members.size(), PartyManager.max_party_size]
	
	var member_container = party_card.get_node("%PartiesContainer")
	for child in member_container.get_children():
		child.queue_free()
	
	if party.members.size() > 0:
		for member in party.members:
			create_party_member_display(member_container, member)
	else:
		create_empty_party_slots(member_container)

func create_party_member_display(container: Node, member: Dictionary):
	var memberscene = load("res://party_member.tscn")
	var membercontainer = memberscene.instantiate()
	container.add_child(membercontainer)
	
	membercontainer.get_node("%HeroName").text = member.name
	membercontainer.get_node("%HeroClass").text = member.class
	membercontainer.get_node("%HeroLevel").text = "Lvl %d" % member.level
	
	var class_icon = PartyManager.get_class_icon(member.class)
	if class_icon:
		membercontainer.get_node("CenterContainer/TextureRect").texture = class_icon

func create_empty_party_slots(container: Node):
	for i in range(PartyManager.max_party_size):
		var memberscene = load("res://party_member.tscn")
		var membercontainer = memberscene.instantiate()
		container.add_child(membercontainer)
		
		membercontainer.get_node("%HeroName").text = "Empty"
		membercontainer.get_node("%HeroClass").text = ""
		membercontainer.get_node("%HeroLevel").text = ""
		membercontainer.modulate = Color(0.5, 0.5, 0.5, 0.5)
