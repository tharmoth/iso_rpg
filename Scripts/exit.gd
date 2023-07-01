class_name Exit extends Interactable

@export var target_scene : String = "res://Scenes/levels/forest.tscn"

func _ready():
	var player = GlobalPersistant.player
	if player.spawn == target_scene:
		add_sibling.call_deferred(player)
		player.position = position

func loot(player : Character):
	GlobalPersistant.player.spawn = get_tree().current_scene.scene_file_path
	GlobalPersistant.change_scene(target_scene)
	
