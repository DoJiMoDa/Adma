extends Node

var parties=[]
var max_party_size = 5
signal onpartyupdated(party: Party)
 
func add_adventurer_to_party(adventurer):
	var success=false
	var adventurerParty = null
	for party in parties:
		if not party.IsFull():
			party.addtoparty(adventurer)
			adventurerParty=party
			success=true
			onpartyupdated.emit(adventurerParty)
			return
	if not success: 
		var newParty=Party.new()
		newParty.addtoparty(adventurer)
		parties.append(newParty)
		onpartyupdated.emit(adventurerParty)

func get_all_parties():
	return parties

func get_class_icon(HeroClass_name: String) -> Texture2D:
	# Map class names to icon paths
	var icon_path = AdventurerData.CLASS_ICONS.get(HeroClass_name, "")
	if icon_path != "" and ResourceLoader.exists(icon_path):
		return load(icon_path)
	return null
