class_name Exit extends Interactable

@export var target_scene : String = "default"

func _ready():
	super()
	print("last: " + str(Party.last_scene) + ", target: " + target_scene + ", equals nothing: " + str(Party.last_scene == ""))
	for player in Party.players:
		if Party.last_scene == target_scene or Party.last_scene == "":
			add_sibling.call_deferred(player)
			if get_parent().get_parent().get("camera") != null:
				get_parent().get_parent().get("camera").position = position
		
		if Party.last_scene == target_scene:
			player.position = position + player.party_offset

func loot(_player : BCharacter):
	Party.change_scene(target_scene)
	
