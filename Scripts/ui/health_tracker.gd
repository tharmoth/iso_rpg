extends Node

var rpg_player : RPGCharacter
@export var reverse : bool = false

func _ready():
	set_player(null)
	if get_parent() is Control:
		GlobalPersistant.player_selected.connect(set_player)
	
func set_player(player : Player):	
	if get_parent() is BCharacter:
		rpg_player = get_parent().rpg_character
	else :
		var index = int(get_parent().name.right(1))
		if GlobalPersistant.players.size() > index:
			rpg_player = GlobalPersistant.players[index].rpg_character
			get_parent().visible = true
		elif get_parent() is Control:
			get_parent().visible = false
		
	if rpg_player != null:
		if not rpg_player.health_changed.is_connected(_update):
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
