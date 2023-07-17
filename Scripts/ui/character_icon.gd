extends TextureRect

var rpg_player : Player :
	set(value):
		rpg_player = value
		if not rpg_player.selection_changed.is_connected(update_selection_border):
			rpg_player.selection_changed.connect(update_selection_border)
		update_selection_border()
		texture = rpg_player.get_icon()
var index : int

func _ready():
	index = int(get_parent().name.right(1))
	# This is a part of an autoload wait for the start screen to load in the players
	Party.party_changed.connect(update_player)


func update_player():
	if index < Party.party_size:
		rpg_player = Party.players[index]


func _unhandled_input(event):
	#Just for Taylor
	if Input.is_action_just_pressed("select_player_" + str(index + 1)):
		Party.select_one_member(rpg_player)


func _gui_input(event):
	if (Input.is_action_just_pressed("interact_ctrl") or Input.is_action_just_pressed("interact_shift")) and GUI.get_node("%Inventory").visible == false:
		rpg_player.selected = true
	elif Input.is_action_just_pressed("interact"):
		Party.select_one_member(rpg_player)


func update_selection_border():
	if rpg_player != null and rpg_player.selected:
		%SelectedOutline.visible = true
	else:
		%SelectedOutline.visible = false


func _can_drop_data(at_position, data):
	return Party.party_leader != rpg_player or ItemDatabase.get_item(data["origin"].item_name).slot == "consumable"


func _drop_data(at_position, data):
	var origin_item_name = data["origin"].item_name
	var origin_item = ItemDatabase.get_item(origin_item_name)
	
	rpg_player = Party.players[index]
	if Party.party_leader != rpg_player:
		var successfully_added = rpg_player.rpg_character.add_item_to_inventory(origin_item_name)
		
		if successfully_added:
			data["origin"].item_name = ""
	elif origin_item.slot == "consumable":
		rpg_player.rpg_character.consume()
		data["origin"].item_name = ""
	
	GUI.get_node("%Inventory").data = null
