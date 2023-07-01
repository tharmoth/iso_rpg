class_name Persistant extends Node

var player := preload("res://Scenes/player.tscn").instantiate()
var gui := preload("res://Scenes/gui.tscn").instantiate()
var console : RichTextLabel = gui.get_node("%Console")

func _ready():
#	load_player()
	GlobalPersistant.player.add_child.call_deferred(gui)
#	if player.scene != null:
#		change_scene(player.scene)
	
	
func change_scene(target_scene : String):
	if GlobalPersistant.player.get_parent() != null:
		GlobalPersistant.player.get_parent().remove_child(GlobalPersistant.player)

	if get_tree().current_scene.has_method("save_level"):
		get_tree().current_scene.save_level()

	get_tree().change_scene_to_file(target_scene)

	GlobalCursor.reset()

func print(text : String) -> void:
#	GlobalPersistant.console.text = GlobalPersistant.console.text + text + "\n"
#	GlobalPersistant.console.scroll_to_line(GlobalPersistant.console.get_line_count()-1)
	print(text)

#############################################
# Saveing and Loading Variables and Methods #
#############################################
#@onready var filepath = "user://savegame_player.save"
#func save_player():
#	print("save " + filepath)
#	var save_game = FileAccess.open(filepath, FileAccess.WRITE)
##	var save_nodes = get_tree().get_nodes_in_group("Persist")
#	var save_nodes = [player]
#	for node in save_nodes:
#		# Check the node is an instanced scene so it can be instanced again during load.
#		if node.scene_file_path.is_empty():
#			print("persistent node '%s' is not an instanced scene, skipped" % node.name)
#			continue
#
#		# Check the node has a save function.
#		if !node.has_method("save"):
#			print("persistent node '%s' is missing a save() function, skipped" % node.name)
#			continue
#
#		# Call the node's save function.
#		var node_data = node.call("save")
#
#		# JSON provides a static method to serialized JSON string.
#		var json_string = JSON.stringify(node_data)
#
#		if json_string == null:
#			print("persistent node '%s' failed to return a save value, skipped" % node.name)
#			continue
#
#		# Store the save dictionary as a new line in the save file.
#		save_game.store_line(json_string)
#
#
#func load_player():
#	print("load " + filepath)
#	if not FileAccess.file_exists(filepath):
#		return # Error! We don't have a save to load.
#
#	# We need to revert the game state so we're not cloning objects
#	# during loading. This will vary wildly depending on the needs of a
#	# project, so take care with this step.
#	# For our example, we will accomplish this by deleting saveable objects.
#	var save_nodes = get_tree().get_nodes_in_group("Persist")
#	for i in save_nodes:
#		i.queue_free()
#
#	# Load the file line by line and process that dictionary to restore
#	# the object it represents.
#	var save_game = FileAccess.open(filepath, FileAccess.READ)
#	while save_game.get_position() < save_game.get_length():
#		var json_string = save_game.get_line()
#
#		# Creates the helper class to interact with JSON
#		var json = JSON.new()
#
#		# Check if there is any error while parsing the JSON string, skip in case of failure
#		var parse_result = json.parse(json_string)
#		if not parse_result == OK:
#			print("JSON Parse Error: ", json.get_error_message(), " in ", json_string, " at line ", json.get_error_line())
#			continue
#
#		# Get the data from the JSON object
#		var node_data = json.get_data()
#
#		# Firstly, we need to create the object and add it to the tree and set its position.
#		var new_object = load(node_data["filename"]).instantiate()
#		player = new_object
#		new_object.position = Vector2(node_data["position_x"], node_data["position_y"])
#
#		# Now we set the remaining variables.
#		for i in node_data.keys():
#			if i == "filename" or i == "parent" or i == "position_x" or i == "position_y":
#				continue
#			new_object.set(i, node_data[i])




