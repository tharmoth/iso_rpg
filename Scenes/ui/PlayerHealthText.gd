extends RichTextLabel

@onready var rpg_player = GlobalPersistant.player.rpg_character

func _ready():
	rpg_player.health_changed.connect(_update)
	_update(rpg_player.health, rpg_player.health)
	
func _update(old_health, new_health):
	text = str(rpg_player.health) + "/" + str(rpg_player.max_health)
