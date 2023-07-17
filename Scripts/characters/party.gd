extends Node

var player_scene = preload("res://Scenes/characters/player_character.tscn")

signal party_changed()
var players : Array[Player] = [] :
	set(value):
		var changed = players != value
		players = value
		if changed:
			set_first_selected_as_leader()
			party_changed.emit()
		
var console : RichTextLabel
var lock_camera = false
var party_size = 2
var scene = "res://Scenes/levels/world.tscn"
var last_scene = ""
var map_position = Vector2.ZERO

signal looting_inventory_changed()
var looting_inventory = ItemContainer.new() :
	set(value):
		looting_inventory = value
		looting_inventory_changed.emit()


func get_new_party() -> Array[Player]:
	var new_players : Array[Player] = []
	for i in range(0, party_size):
		var player = player_scene.instantiate()
		new_players.append(player)
		player.selection_changed.connect(set_first_selected_as_leader)
	scene = "res://Scenes/levels/world.tscn"
	last_scene = scene
	map_position = Vector2.ZERO
	gold = 75
	return new_players


func change_scene(target_scene : String):
	for player in players:
		if player.get_parent() != null:
			player.get_parent().remove_child(player)

	if get_tree().current_scene.has_method("save_level"):
		get_tree().current_scene.save_level()
	
	last_scene = scene
	scene = target_scene
	get_tree().change_scene_to_file(target_scene)
	GlobalCursor.reset()


###############################
# Party interaction functions #
###############################
signal gold_changed()
var gold : int = 0 :
	set(value):
		gold = value
		gold_changed.emit()
var reputation = 10


func add_xp(xp : int):
	GUI.post("Party gained " + str(xp) + " xp!")
	for player in players:
		player.add_xp(floori(xp / players.size()))


#############################
# Party selection functions #
#############################
signal party_leader_changed(player : Player)
var party_leader : Player :
	set(value):
		party_leader = value
		if not party_leader.selected:
			party_leader.selected = true
		party_leader.confirmation_fx()
		party_leader_changed.emit(party_leader)


func get_selected_players() -> Array:
	var selected_players = []
	for player in players:
		if player.selected:
			selected_players.append(player)
	return selected_players


func set_selected_players(selected_players : Array) -> void:
	for player in players:
		player.selected = player in selected_players


func select_one_member(player_to_select : Player) -> void:
	for player in players:
		player.selected = player == player_to_select


func set_first_selected_as_leader() -> void:
	for player in players:
		if player.selected:
			party_leader = player
			return


#############################################
# Saveing and Loading Variables and Methods #
#############################################
@onready var filepath = "user://savegame_Player.save"
func save_party():
	var save_game = FileAccess.open(filepath, FileAccess.WRITE)
#	var save_nodes = get_tree().get_nodes_in_group("Persist")
	var save_nodes = []
	save_nodes.append_array(players)
	save_nodes.append(self)
	for node in save_nodes:
		# Check the node has a save function.
		if !node.has_method("save"):
			print("persistent node '%s' is missing a save() function, skipped" % node.name)
			continue

		# Call the node's save function.
		var node_data = node.call("save")

		# JSON provides a static method to serialized JSON string.
		var json_string = JSON.stringify(node_data)

		if json_string == null:
			print("persistent node '%s' failed to return a save value, skipped" % node.name)
			continue

		# Store the save dictionary as a new line in the save file.
		save_game.store_line(json_string)


func load_party():
	if not FileAccess.file_exists(filepath):
		return # Error! We don't have a save to load.

	var new_players : Array[Player] = []

	# Load the file line by line and process that dictionary to restore
	# the object it represents.
	var save_game = FileAccess.open(filepath, FileAccess.READ)
	while save_game.get_position() < save_game.get_length():
		var json_string = save_game.get_line()

		# Creates the helper class to interact with JSON
		var json = JSON.new()

		# Check if there is any error while parsing the JSON string, skip in case of failure
		var parse_result = json.parse(json_string)
		if not parse_result == OK:
			print("JSON Parse Error: ", json.get_error_message(), " in ", json_string, " at line ", json.get_error_line())
			continue

		# Get the data from the JSON object
		var node_data = json.get_data()

		if node_data["filename"] == get_scene_file_path():
			for i in node_data.keys():
				set(i, jsonify.godotify(node_data[i]))
		else:
			# Firstly, we need to create the object and add it to the tree and set its position.
			var loaded_player = load(node_data["filename"]).instantiate()

			# Now we set the remaining variables.
			for i in node_data.keys():
				loaded_player.set(i, jsonify.godotify(node_data[i]))
			
			
			new_players.append(loaded_player)
			loaded_player.selection_changed.connect(set_first_selected_as_leader)
			loaded_player.selected = true
	players = new_players
	Party.last_scene = ""
	
func save():
	return {
		"filename" : get_scene_file_path(),
		"scene" : scene,
		"map_position" : jsonify.jsonify(map_position),
		"gold" : gold,
		"reputation" : reputation,
		}
