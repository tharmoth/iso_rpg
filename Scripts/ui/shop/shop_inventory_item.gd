class_name ShopInventoryItem extends HBoxContainer

var item : String

signal selected_changed(new_value)
var selected : bool = false : 
	set(value):
		selected = value
		selected_changed.emit(selected)

func _ready():
	if item != "":
		%Icon.texture = ItemDatabase.get_item_icon(item)
		%Name.text = ItemDatabase.get_item(item)["name"].replace("_", " ")
		%Value.text = str(get_parent().markup(ItemDatabase.get_item_value(item)))

func _gui_input(event):
	if Input.is_action_just_released("interact"):
		selected = not selected
		%Selected.visible = selected
