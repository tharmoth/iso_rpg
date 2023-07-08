extends Node

var rpg_player : RPGCharacter
@export var reverse : bool = false

func _ready():
	if get_parent() is BCharacter:
		rpg_player = get_parent().rpg_character
	else :
		rpg_player = GlobalPersistant.player.rpg_character
		
	
	rpg_player.health_changed.connect(_update)
	_update(rpg_player.health, rpg_player.health)
	
func _update(old_health, new_health):
	if get("max_value") != null:
		set("max_value", rpg_player.max_health)
		
	if get("value") != null:
		if reverse:
			set("value", rpg_player.max_health - rpg_player.health)
		else:
			set("value", rpg_player.health)

	if get("text") != null:
		set("text", str(rpg_player.health) + "/" + str(rpg_player.max_health))
