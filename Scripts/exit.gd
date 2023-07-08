class_name Exit extends Interactable

@export var target_scene : String = "default"

func _ready():
	super()
	var player = GlobalPersistant.player
	if player.spawn == target_scene and player.spawn_scene == null and player.get_parent() == null:
		add_sibling.call_deferred(player)
		player.position = position
		if get_parent().get_parent().get("camera") != null:
			get_parent().get_parent().get("camera").position = position
	elif player.spawn_scene != null and player.get_parent() == null:
		add_sibling.call_deferred(player)
		player.spawn_scene = null
		if get_parent().get_parent().get("camera") != null:
			get_parent().get_parent().get("camera").position = position


func loot(player : BCharacter):
	GlobalPersistant.player.spawn = get_tree().current_scene.scene_file_path
	GlobalPersistant.change_scene(target_scene)
	
