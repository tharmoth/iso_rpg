extends Node

class_name Items

enum ITEM_NAME {longsword, mace, full_plate, leather, farmer, shield, buckler}

const items = {
	# Weapons
	ITEM_NAME.longsword : {"slot" : "weapon", "damage" : "1d8", "texture" : preload("res://Assets/pvg/male/weapon/longsword.png")},
	ITEM_NAME.mace      : {"slot" : "weapon", "damage" : "1d6+1", "texture" : preload("res://Assets/pvg/male/weapon/mace.png")},
	# Armors
	ITEM_NAME.full_plate : {"slot" : "body", "protection" : 17, "texture" : preload("res://Assets/pvg/male/premade/full_plate.png")},
	ITEM_NAME.leather    : {"slot" : "body", "protection" : 12, "texture" : preload("res://Assets/pvg/male/premade/leather.png")},
	ITEM_NAME.farmer    : {"slot" : "body", "protection" : 10, "texture" : preload("res://Assets/pvg/male/premade/farmer.png")},
	# Shields
	ITEM_NAME.shield : {"slot" : "shield", "block_chance" : 2, "texture" : preload("res://Assets/pvg/male/shield/shield_1.png")},
	ITEM_NAME.buckler : {"slot" : "shield", "block_chance" : 1, "texture" : preload("res://Assets/pvg/male/shield/shield_2.png")},
}

static func calculate_damage(damage_string : String) -> int:
	var damage := 0
	
	var num_dice_loc = damage_string.find("d")
	var num_dice = 0
	var dice_loc = damage_string.find("+")
	var dice = 0
	
	var addition = 0
	if num_dice_loc > -1:
		num_dice = damage_string.substr(0, num_dice_loc)
		if dice_loc > -1:
			dice = damage_string.substr(num_dice_loc + 1, dice_loc - 2)
		else:
			dice = damage_string.substr(num_dice_loc + 1)
		
	if dice_loc > -1:
		addition = damage_string.substr(dice_loc + 1)

	for i in num_dice:
		damage += RandomNumberGenerator.new().randi_range(1, int(dice))
	
	damage += int(addition)
	return damage
