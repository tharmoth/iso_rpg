extends PanelContainer

var item_name : String = "" :
	set(value):
		item_name = value
		$MarginContainer/TextureRect.texture = ItemDatabase.get_item_icon(item_name)

var slot_index : 
	get:
		if slot_index == null:
			slot_index = int(name.right(2))
		return slot_index

var active_player
	
func _ready():
	Party.party_leader_changed.connect(func(player): refresh())
	$MarginContainer/TextureRect.clicked.connect(clicked)

func refresh():
	if active_player != null and active_player.is_connected("equipment_changed", _equpment_changed):
		active_player.equipment_changed.disconnect(_equpment_changed)
	active_player = Party.party_leader.rpg_character
	active_player.equipment_changed.connect(_equpment_changed)
	
	item_name = Party.party_leader.rpg_character.inventory[slot_index]

func _equpment_changed(slot, new_value):
	if int(slot.right(2)) == slot_index:
		item_name = Party.party_leader.rpg_character.inventory[slot_index]

func clicked():
	GUI.button_player.play()
	if Party.looting_inventory.has_open():
		Party.looting_inventory.add_item(item_name)
		Party.party_leader.rpg_character.add_item_to_inventory_slot(slot_index, "")
