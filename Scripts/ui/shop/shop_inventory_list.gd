extends Container

var active_player

func _ready():
	Party.party_leader_changed.connect(func(player): refresh())
	%SellButton.pressed.connect(_on_sell_pressed)
	%SellButton.pressed.connect(%MoneyPlayer.play)
	%SellButton.button_down.connect(%ButtonPressAudioPlayer.play)
	
func _on_sell_pressed():
	var price = 0
	for child in get_selected_children():
		price += ItemDatabase.get_item_value(child.item)
		active_player.rpg_character.inventory[active_player.rpg_character.inventory.find(child.item)] = ""
	
	Party.gold += price
	refresh()
	update_price()

func update_price():
	var price = 0
	for child in get_selected_children():
		price += ItemDatabase.get_item_value(child.item)
		
	%Price.text = str(price)

func markup(price : int) -> int:
	return price

func refresh():
	if active_player != null:
		active_player.rpg_character.equipment_changed.disconnect(_items_added)
	active_player = Party.party_leader
	Party.party_leader.rpg_character.equipment_changed.connect(_items_added)
	for child in get_children():
		remove_child(child)
	
	var inventory_item_scene : PackedScene = load("res://Scenes/ui/shop/shop_item.tscn")
	for item in active_player.rpg_character.inventory:
		if item != "":
			var list_item = inventory_item_scene.instantiate()
			list_item.item = item
			list_item.selected_changed.connect(func(value): update_price())
			add_child(list_item)

func _items_added(new, old):
	refresh()

func get_selected_children():
	var selected_children = []
	for child in get_children():
		if child.selected:
			selected_children.append(child)
	return selected_children
