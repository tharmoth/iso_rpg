extends RichTextLabel

func _ready():
	text = GlobalPersistant.player.rpg_character.print_stats(false)
	GlobalPersistant.player.rpg_character.equipment_changed.connect(func(slot, item): text = GlobalPersistant.player.rpg_character.print_stats(false))
