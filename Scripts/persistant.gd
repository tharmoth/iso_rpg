class_name Persistant extends Node

var players : Array[Player]
var console : RichTextLabel
var selected_player : Player :
	set(value):
		selected_player = value
		if not selected_player.selected:
			selected_player.selected = true
		player_selected.emit(selected_player)

signal player_selected(player : Player)

var lock_camera = false
var party_size = 2

func _ready():
	reset()
	
func reset():
	print("Resetting characters!")
	players.clear()
	for i in range(0, 2):
		var player = preload("res://Scenes/characters/player_character.tscn").instantiate()
		player.party_offset = Vector2(0, i * 60)
		players.append(player)
		player.selection_changed.connect(set_first_selected_player_as_leader)
		player.selected = true
	console = GUI.get_node("%Console")
	
func change_scene(target_scene : String):
	for player in players:
		if player.get_parent() != null:
			player.get_parent().remove_child(player)

	if get_tree().current_scene.has_method("save_level"):
		get_tree().current_scene.save_level()

	get_tree().change_scene_to_file(target_scene)

	GlobalCursor.reset()

func post(text : String) -> void:
	GlobalPersistant.console.text = GlobalPersistant.console.text + text + "\n"
	GlobalPersistant.console.scroll_to_line(GlobalPersistant.console.get_line_count()-1)
	print(text)

func set_first_selected_player_as_leader():
	for player in players:
		if player.selected:
			selected_player = player
			return
			
#############################################
# Saveing and Loading Variables and Methods #
#############################################
@onready var filepath = "user://savegame_Player.save"
func save_player():
	var save_game = FileAccess.open(filepath, FileAccess.WRITE)
#	var save_nodes = get_tree().get_nodes_in_group("Persist")
	var save_nodes = players
	for node in save_nodes:
		# Check the node is an instanced scene so it can be instanced again during load.
		if node.scene_file_path.is_empty():
			print("persistent node '%s' is not an instanced scene, skipped" % node.name)
			continue

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

func load_player():
	if not FileAccess.file_exists(filepath):
		return # Error! We don't have a save to load.

	players.clear()

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

		# Firstly, we need to create the object and add it to the tree and set its position.
		var loaded_player = load(node_data["filename"]).instantiate()

		# Now we set the remaining variables.
		for i in node_data.keys():
			loaded_player.set(i, jsonify.godotify(node_data[i]))
		
		
		players.append(loaded_player)
		loaded_player.selection_changed.connect(set_first_selected_player_as_leader)
		loaded_player.selected = true
	print("Loading characters!")
