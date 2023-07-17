extends Control

var multisprite = {}
var active_player = null

func _ready():
	Party.party_leader_changed.connect(func(player): refresh())

func _items_added(new, old):
	refresh()

func refresh():
	if active_player != null:
		active_player.rpg_character.equipment_changed.disconnect(_items_added)
	active_player = Party.party_leader
	Party.party_leader.rpg_character.equipment_changed.connect(_items_added)
	
	multisprite = Party.party_leader.get_node("Sprites").save()
	$Sprites.weapon = Party.party_leader.rpg_character.weapon
	$Sprites.armor = Party.party_leader.rpg_character.armor
	$Sprites.shield = Party.party_leader.rpg_character.shield
	$Sprites.refresh()
