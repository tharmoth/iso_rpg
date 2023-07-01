class_name Items extends Node

enum ITEM_NAME {unarmed, battle_axe, long_bow, short_bow, dagger, halberd, mace, quarterstaff, longsword, bastard_sword, crossbow, full_plate, hide, clothing, shield, buckler}

const items = {
	# Weapons
	ITEM_NAME.unarmed       : {"slot" : "weapon", "damage" : "1",     "texture" : null,                                             "price" : "0",  "animation" : "UNARMED"},
	ITEM_NAME.battle_axe    : {"slot" : "weapon", "damage" : "1d8",   "texture" : "res://Assets/rpgtools/male/Weapons/axe.png",     "price" : "5",  "animation" : "1H"},
	ITEM_NAME.long_bow      : {"slot" : "weapon", "damage" : "1d8",   "texture" : "res://Assets/rpgtools/male/Weapons/bow.png",     "price" : "75", "animation" : "BOW"},
	ITEM_NAME.short_bow     : {"slot" : "weapon", "damage" : "1d6",   "texture" : "res://Assets/rpgtools/male/Weapons/bow.png",     "price" : "30", "animation" : "BOW"},
	ITEM_NAME.dagger        : {"slot" : "weapon", "damage" : "1d4",   "texture" : "res://Assets/rpgtools/male/Weapons/dagger.png",  "price" : "2",  "animation" : "1H"},
	ITEM_NAME.halberd       : {"slot" : "weapon", "damage" : "2d4",   "texture" : "res://Assets/rpgtools/male/Weapons/halberd.png", "price" : "10", "animation" : "POLEARM"},
	ITEM_NAME.mace          : {"slot" : "weapon", "damage" : "1d6+1", "texture" : "res://Assets/rpgtools/male/Weapons/mace.png",    "price" : "8",  "animation" : "1H"},
	ITEM_NAME.quarterstaff  : {"slot" : "weapon", "damage" : "1d6",   "texture" : "res://Assets/rpgtools/male/Weapons/staff.png",   "price" : "0",  "animation" : "POLEARM"},
	ITEM_NAME.longsword     : {"slot" : "weapon", "damage" : "1d8",   "texture" : "res://Assets/rpgtools/male/Weapons/sword.png",   "price" : "15", "animation" : "1H"},
	ITEM_NAME.bastard_sword : {"slot" : "weapon", "damage" : "1d8",   "texture" : "res://Assets/rpgtools/male/Weapons/sword-2.png", "price" : "25", "animation" : "1H"},
	ITEM_NAME.crossbow      : {"slot" : "weapon", "damage" : "1d4+1", "texture" : "res://Assets/rpgtools/male/Weapons/xbow.png",    "price" : "50", "animation" : "XBOW"},

	# Armors
	ITEM_NAME.full_plate : {"slot" : "body", "ac" : 19, "top_texture" : "res://Assets/rpgtools/male/Top/plate-shiny.png", "bottom_texture" : "res://Assets/rpgtools/male/Bottom/plate-shiny.png", "price" : "7000"},
	ITEM_NAME.hide       : {"slot" : "body", "ac" : 12, "top_texture" : "res://Assets/rpgtools/male/Top/hide.png",        "bottom_texture" : "res://Assets/rpgtools/male/Bottom/hide.png",        "price" : "5"},
	ITEM_NAME.clothing   : {"slot" : "body", "ac" : 10, "top_texture" : "res://Assets/rpgtools/male/Top/shirt.png",       "bottom_texture" : "res://Assets/rpgtools/male/Bottom/black.png",       "price" : "0"},
	# Pants
	# Shields
#	ITEM_NAME.shield : {"slot" : "shield", "ac" : 2, "texture" : preload("res://Assets/pvg/male/shield/shield_1.png")},
#	ITEM_NAME.buckler : {"slot" : "shield", "ac" : 1, "texture" : preload("res://Assets/pvg/male/shield/shield_2.png")},
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
		
	if dice_loc == -1 and num_dice_loc == -1:
		damage = int(damage_string)

	for i in num_dice:
		damage += RandomNumberGenerator.new().randi_range(1, int(dice))

	damage += int(addition)
	return damage
