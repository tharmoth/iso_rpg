extends Node

class_name Items

enum ITEM_NAME {longsword, mace, full_plate, leather, farmer, shield, buckler}

const items = {
	# Weapons
	ITEM_NAME.longsword : {"slot" : "weapon", "damage" : 50.0, "texture" : preload("res://Assets/pvg/male/weapon/longsword.png")},
	ITEM_NAME.mace      : {"slot" : "weapon", "damage" : 40.0, "texture" : preload("res://Assets/pvg/male/weapon/mace.png")},
	# Armors
	ITEM_NAME.full_plate : {"slot" : "body", "protection" : 50.0, "texture" : preload("res://Assets/pvg/male/premade/full_plate.png")},
	ITEM_NAME.leather    : {"slot" : "body", "protection" : 20.0, "texture" : preload("res://Assets/pvg/male/premade/leather.png")},
	ITEM_NAME.farmer    : {"slot" : "body", "protection" : 5.0, "texture" : preload("res://Assets/pvg/male/premade/farmer.png")},
	# Shields
	ITEM_NAME.shield : {"slot" : "shield", "block_chance" : 20.0, "texture" : preload("res://Assets/pvg/male/shield/shield_1.png")},
	ITEM_NAME.buckler : {"slot" : "shield", "block_chance" : 10.0, "texture" : preload("res://Assets/pvg/male/shield/shield_2.png")},
}
