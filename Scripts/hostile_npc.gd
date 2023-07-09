class_name HostileNPC extends BCharacter

func _ready():
	display_name = "Bandit"
	var weapon_roll = RandomNumberGenerator.new().randf()
	if weapon_roll > .75:
		rpg_character.equip("weapon", "long_sword")
	elif weapon_roll > .5:
		rpg_character.equip("weapon", "battle_axe")
	else:
		rpg_character.equip("weapon", "dagger")
		
	if RandomNumberGenerator.new().randf() > .75:
		rpg_character.equip("armor", "hide")
	else:
		rpg_character.equip("armor", "leather")
	
	if RandomNumberGenerator.new().randf() > .75:
		rpg_character.equip("shield", "medium_shield")
	super()
