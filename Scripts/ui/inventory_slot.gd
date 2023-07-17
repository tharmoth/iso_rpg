class_name InventorySlot extends TextureRect

var active_player = null

@export var item_name : String = "" :
	set(value):
		item_name = value
		
		item = ItemDatabase.get_item(item_name)
		if slot == "quick_slots":
			active_player.rpg_character.add_item_to_quick_slot(slot_index, item_name)
		elif slot == "inventory":
			active_player.rpg_character.add_item_to_inventory_slot(slot_index, item_name)
		elif slot != "inventory":
			active_player.equip(slot, item_name)

		
var item : Dictionary = {} :
	set(value):
		item = value
		if item == {} or item.value == -1:
			texture = null
			return
		
		texture = ItemDatabase.get_item_icon(item_name)
		

@export var slot : String = "inventory"
var slot_index : 
	get:
		if slot_index == null:
			# Use the name of the parent to determine what slot this should represent
			slot_index = int(get_parent().get_parent().name.right(2)) - 1
		return slot_index

func _ready():
	Party.party_leader_changed.connect(func(player): refresh())

func refresh():
	active_player = Party.party_leader
	if slot == "consumable":
		pass
	elif slot == "quick_slots":
		item_name = active_player.rpg_character.quick_slots[slot_index]
	elif slot != "inventory":
		item_name = active_player.rpg_character.get(slot)
	elif slot == "inventory":
		item_name = active_player.rpg_character.inventory[slot_index]


func _get_drag_data(at_position):
	if item_name == "" or item.value == -1:
		return null
		
	var cached_texture = texture
	var data = {"origin" : self,
	"reset" : func(): 
		texture = cached_texture
		%SheathPlayer.play()
	}

	var drag_texture = TextureRect.new()
	drag_texture.expand = true
	drag_texture.texture = texture
	drag_texture.size = size
	
	var control = Control.new()
	control.add_child(drag_texture)
	drag_texture.position = -0.5 * drag_texture.size
	set_drag_preview(control)

	texture = null
	
	GUI.get_node("%Inventory").data = data

	%DrawPlayer.play()
	return data
	

func _can_drop_data(at_position, data):
	var origin_slot = data["origin"]
	
	# can this slot take the origin item
	var can_drop = slot == "inventory" or origin_slot.item.get("slot") == slot or (origin_slot.item.get("slot") == "consumable" and slot == "quick_slots")
	# can the origin slot thake this item
	can_drop = can_drop and (item_name == "" or origin_slot.slot == "inventory" or origin_slot.slot == item.slot or (origin_slot.slot == "quick_slots" and item.get("slot") == "consumable"))

	return can_drop
	
func _drop_data(at_position, data):
	if slot == "consumable":
		active_player.equip("consumable", data["origin"].item_name)
		data["origin"].item_name = ""
		return
	var current_item_name = item_name
	var current_item = item
	var origin_item_name = data["origin"].item_name
	data["origin"].item_name = "" if current_item_name == "" or current_item.value == -1 else current_item_name
	item_name = origin_item_name
	GUI.get_node("%Inventory").data = null
