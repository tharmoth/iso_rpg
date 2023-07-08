class_name Items extends Node

var _filepath = "res://data/isorpg_loot_data.json"
var item_data : Dictionary

func _ready():
	_load()
	

func _load():
	var item_data_file = FileAccess.open(_filepath, FileAccess.READ)
	var item_data_json = JSON.parse_string(item_data_file.get_as_text())
	item_data_file.close()
	for key in item_data_json.keys():
		var value = item_data_json.get(key)
		for item_key in value.keys():
			var item_value = value.get(item_key)
			item_value["name"] = item_key
			item_value["slot"] = key
			item_data[item_key] = item_value


func get_item(item_name : String) -> Dictionary:
	if item_data.is_empty():
		_load()
	var item = item_data.get(item_name)
	if item != null:
		return item
	return {}


func get_item_value(item_name : String) -> int:
	if item_data.is_empty():
		_load()
	var item = item_data.get(item_name)
	if item != null and item.value != null:
		return item.value
	return -1
	
	
func get_item_icon(item_name : String):
	var texture = null
	var texture_path = "res://Assets/characters/icons/" + item_name + ".png"
	if item_name != null and ResourceLoader.exists(texture_path):
		texture = load(texture_path)
	if item_name != null and texture == null:
		texture_path = "res://Assets/characters/items/" + item_name + ".png"
		if ResourceLoader.exists(texture_path):
			texture = load(texture_path)
	if texture == null:
		texture = load("res://Assets/characters/items/unknown.png")
		push_error("Failed to find icon texture for " + item_name)
	return texture


static func roll_dice(damage_string) -> int:
	damage_string = str(damage_string)
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

	for i in range(0, int(num_dice), 1):
		damage += RandomNumberGenerator.new().randi_range(1, int(dice))

	damage += int(addition)
	return damage

static func empty_slot(slot : String) -> String:
	match slot:
		"weapon":
			return "unarmed"
		"shield":
			return "unarmed_oh"
		"armor":
			return "clothing"
		_:
			return slot
