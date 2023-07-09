extends TextureRect

var rpg_player : Player
var index : int

func _ready():
	GlobalPersistant.player_selected.connect(update_selection_border)
	index = int(get_parent().name.right(1))
	update_selection_border(null)
		
func _gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			GlobalPersistant.selected_player = GlobalPersistant.players[index]

func update_selection_border(_player):
	if GlobalPersistant.players.size() > index and GlobalPersistant.selected_player == GlobalPersistant.players[index]:
		%SelectedOutline.visible = true
	else:
		%SelectedOutline.visible = false
		
func _can_drop_data(at_position, data):
	return GlobalPersistant.selected_player != rpg_player or ItemDatabase.get_item(data["origin"].item_name).slot == "consumable"

func _drop_data(at_position, data):
	var origin_item_name = data["origin"].item_name
	var origin_item = ItemDatabase.get_item(origin_item_name)
	
	rpg_player = GlobalPersistant.players[index]
	if GlobalPersistant.selected_player != rpg_player:
		var successfully_added = rpg_player.rpg_character.add_item_to_inventory(origin_item_name)
		
		if successfully_added:
			data["origin"].item_name = ""
	elif origin_item.slot == "consumable":
		rpg_player.rpg_character.consume()
		data["origin"].item_name = ""
	
	GUI.get_node("%Inventory").data = null
