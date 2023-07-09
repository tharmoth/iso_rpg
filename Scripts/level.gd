extends Node2D

var camera = RTSCam.new()

func _ready():
	load_level()
	add_child(camera)
	camera.position = GlobalPersistant.selected_player.position
	GUI.visible = true

######################################
# Level Saving and Loading Functions #
######################################
@onready var filepath = "user://savegame_" + name + ".save"
var loaded = false


func save_level():
	var save_game = FileAccess.open(filepath, FileAccess.WRITE)
	var save_nodes = get_tree().get_nodes_in_group("Persist")
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
		
func load_level():
	if not FileAccess.file_exists(filepath):
		return # Error! We don't have a save to load.

	# We need to revert the game state so we're not cloning objects
	# during loading. This will vary wildly depending on the needs of a
	# project, so take care with this step.
	# For our example, we will accomplish this by deleting saveable objects.
	var save_nodes = get_tree().get_nodes_in_group("Persist")
	for i in save_nodes:
		i.queue_free()

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
		var new_object = load(node_data["filename"]).instantiate()
		get_node(node_data["parent"]).add_child(new_object)

		# Now we set the remaining variables.
		for i in node_data.keys():
			new_object.set(i, jsonify.godotify(node_data[i]))
			

###########################
# Randomization Functions #
###########################
var seed : int = 0


func get_seed() -> int:
	return seed
