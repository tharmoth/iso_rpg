extends TextureRect

var active_player
var item_name : String
var slot_index : 
	get:
		if slot_index == null:
			# Use the name of the parent to determine what slot this should represent
			slot_index = int(get_parent().get_parent().name.right(2)) - 1
		return slot_index

func _ready():
	Party.party_leader_changed.connect(func(player): refresh())

func refresh():
	if active_player != null:
		active_player.rpg_character.equipment_changed.disconnect(_items_added)
	active_player = Party.party_leader
	Party.party_leader.rpg_character.equipment_changed.connect(_items_added)
	item_name = Party.party_leader.rpg_character.quick_slots[slot_index]
	if item_name != "":
		texture = ItemDatabase.get_item_icon(item_name)
	else:
		texture = null

func _items_added(new, old):
	refresh()

func _gui_input(event):
	if Input.is_action_just_released("interact") and item_name != "":
		$BottlePlayer.play()
		Party.party_leader.rpg_character.equip("consumable", item_name)
		item_name = ""
		Party.party_leader.rpg_character.quick_slots[slot_index] = item_name
		texture = null
		print("yeet")
