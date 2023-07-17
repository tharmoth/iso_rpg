extends Control

var rpg_player : RPGCharacter

func _ready():
	Party.party_changed.connect(set_player)
	set_player()


func set_player():	
	var index = int(get_parent().name.right(1))
	
	if Party.players.size() > index:
		if rpg_player != null:
			if rpg_player.is_connected("xp_gained", _update):
				rpg_player.xp_gained.disconnect(_update)
			if rpg_player.is_connected("leveled_up", _update):
				rpg_player.leveled_up.disconnect(_update)
		rpg_player = Party.players[index].rpg_character
		rpg_player.xp_gained.connect(_update)
		rpg_player.leveled_up.connect(_update)
		_update()
	else:
		visible = false


func _update():
	visible = rpg_player.can_level_up()
