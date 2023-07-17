class_name ItemContainer extends Node

signal container_changed(slot)
var _container   : Array  = ["", "", "", "", "", "", "", "", "", "", "", "", "", "", "", ""]


func get_items():
	return _container


func get_item(slot : int) -> String:
	if slot > -1 and slot < _container.size():
		return _container[slot]
	else:
		return ""


func add_item(item : String) -> bool:
	if item != null and has_open():
		return add_item_to_slot(_first_open(), item)
	else:
		return false


func add_item_to_slot(slot : int, item : String) -> bool:
	if item != null and slot > -1 and slot < _container.size():
		_container[slot] = item
		container_changed.emit(slot, item)
		return true
	else:
		return false


func remove_item(slot : int):
	if slot > -1 and slot < _container.size():
		var item = _container[slot]
		_container[slot] = ""
		return item
	else:
		return ""

func _first_open() -> int:
	return _container.find("") 


func has_open() -> bool:
	return _container.find("") > -1


func open_count() -> int:
	return _container.count("")


func save():
	return {
		"_container" : _container,
		}
