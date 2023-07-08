class_name Data extends Node

func _ready():
	_load_stats()
	_load_classes()
	
#######################################
# Ability Score Variables and Methods #
#######################################
var _stat_filepath = "res://data/isorpg_stat_data.json"
var stat_data : Dictionary
func _load_stats():
	var item_data_file = FileAccess.open(_stat_filepath, FileAccess.READ)
	var item_data_json = JSON.parse_string(item_data_file.get_as_text())
	item_data_file.close()
	for key in item_data_json.keys():
		var value = item_data_json.get(key)
		stat_data[key] = value
		
func get_stat_data(stat : String, score, field : String):
	if stat == "strength":
		push_warning("use get str data instead!")
	return stat_data.get(stat).get(str(score))[field]

func get_str_data(stat : String, strength, exceptional_strength ,field : String):
	if strength == 18 and exceptional_strength != 0:
		return stat_data.get(stat).get(str(strength) + "/" + str(exceptional_strength))[field]
	else:
		return stat_data.get(stat).get(str(strength))[field]

###############################
# Class Variables and Methods #
###############################
var _class_filepath = "res://data/isorpg_class_data.json"
var class_data : Dictionary
func _load_classes():
	var item_data_file = FileAccess.open(_class_filepath, FileAccess.READ)
	var item_data_json = JSON.parse_string(item_data_file.get_as_text())
	item_data_file.close()
	for key in item_data_json.keys():
		var value = item_data_json.get(key)
		class_data[key] = value

func get_class_data(name : String, level : int, field : String):
	return class_data.get(name).get(str(level))[field]
