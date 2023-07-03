class_name Persistant extends Node

var player : Node2D
var gui : CanvasLayer
var console : RichTextLabel

func _ready():
	reset()
	
func reset():
	player = preload("res://Scenes/characters/player_character.tscn").instantiate()
	gui = preload("res://Scenes/ui/gui.tscn").instantiate()
	console = gui.get_node("%Console")
	GlobalPersistant.player.add_child.call_deferred(gui)
	
func change_scene(target_scene : String):
	if GlobalPersistant.player.get_parent() != null:
		GlobalPersistant.player.get_parent().remove_child(GlobalPersistant.player)

	if get_tree().current_scene.has_method("save_level"):
		get_tree().current_scene.save_level()

	get_tree().change_scene_to_file(target_scene)

	GlobalCursor.reset()

func print(text : String) -> void:
	GlobalPersistant.console.text = GlobalPersistant.console.text + text + "\n"
	GlobalPersistant.console.scroll_to_line(GlobalPersistant.console.get_line_count()-1)
	print(text)

#############################################
# Saveing and Loading Variables and Methods #
#############################################
@onready var filepath = "user://savegame_Player.save"
func save_player():
	print("save " + filepath)
	var save_game = FileAccess.open(filepath, FileAccess.WRITE)
#	var save_nodes = get_tree().get_nodes_in_group("Persist")
	var save_nodes = [player]
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
	print("load " + filepath)
	if not FileAccess.file_exists(filepath):
		return # Error! We don't have a save to load.

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
			
		player = loaded_player
		gui = preload("res://Scenes/ui/gui.tscn").instantiate()
		console = gui.get_node("%Console")
		GlobalPersistant.player.add_child.call_deferred(gui)
