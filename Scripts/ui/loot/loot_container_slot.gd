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

var active_container

func _ready():
	Party.looting_inventory_changed.connect(swap_containers)
	swap_containers()
	
	$MarginContainer/TextureRect.clicked.connect(clicked)


func swap_containers():
	if active_container != null and active_container.is_connected("container_changed", _container_changed):
		active_container.container_changed.disconnect(_container_changed)
	Party.looting_inventory.container_changed.connect(_container_changed)
	refresh()

func _container_changed(slot, item):
	refresh()


func refresh():
	item_name = Party.looting_inventory.get_item(slot_index)	


func clicked():
	GUI.button_player.play()
	var player = Party.party_leader.rpg_character
	if player.has_open_inventory_slot() and item_name != "":
		player.add_item_to_inventory(Party.looting_inventory.remove_item(slot_index))
		item_name = ""
