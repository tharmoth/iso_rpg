extends VBoxContainer

func _ready():
#	Party.party_leader_changed.connect(func(player): refresh())
	%BuyButton.pressed.connect(_on_buy_pressed)
	%BuyButton.pressed.connect(%MoneyPlayer.play)
	%BuyButton.button_down.connect(%ButtonPressAudioPlayer.play)
	
func _on_buy_pressed():
	for child in get_selected_children():
		Party.gold -= markup(ItemDatabase.get_item_value(child.item))
		Party.party_leader.add_item(child.item)
#		active_player.rpg_character.inventory[active_player.rpg_character.inventory.find(child.item)] = ""
	
	refresh()
	update_cost()

func update_cost():
	var price = 0
	for child in get_selected_children():
		price += markup(ItemDatabase.get_item_value(child.item))
	
	%BuyButton.disabled = price > Party.gold and get_selected_children().size() <= Party.party_leader.rpg_character.open_inventory_slots()
	%Cost.text = str(price)

var store_sell_markup = 1.5
func markup(price : int) -> int:
	var charisma_mod = Database.get_stat_data("charisma", Party.party_leader.rpg_character.charisma, "price")
	var reputation_mod = Database.get_stat_data("reputation", Party.reputation, "price")
	
	return max(price * (store_sell_markup * (reputation_mod + charisma_mod - 1)), 1)

func refresh():
	for child in get_children():
		remove_child(child)
	
	var inventory_item_scene : PackedScene = load("res://Scenes/ui/shop/shop_item.tscn")
#	for item in ["leather", "studded_leather", "hide", "chain_shirt", "chain_mail", "plate_mail", "full_plate"]:
	for item in ItemDatabase.item_data.keys():
		if item != "" and ItemDatabase.get_item_value(item) > 0:
			var list_item = inventory_item_scene.instantiate()
			list_item.item = item
			list_item.selected_changed.connect(func(value): update_cost())
			add_child(list_item)

func get_selected_children():
	var selected_children = []
	for child in get_children():
		if child.selected:
			selected_children.append(child)
	return selected_children
