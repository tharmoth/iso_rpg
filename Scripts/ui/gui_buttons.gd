extends Control

func _ready():
	%ExitButton.pressed.connect(_on_exit_pressed)
	%ExitButton.button_down.connect($ButtonPressAudioPlayer.play)
	
	%InventoryButton.toggled.connect(_on_gear_pressed)
	%InventoryButton.button_down.connect($ButtonPressAudioPlayer.play)
	
	%ShopButton.visible = false
	%ShopButton.toggled.connect(_on_shop_pressed)
	%ShopButton.button_down.connect($ButtonPressAudioPlayer.play)
	
	%CameraButton.toggled.connect(camera)
	%CameraButton.button_down.connect($ButtonPressAudioPlayer.play)
#	%CameraButton.set_pressed_no_signal(Party.lock_camera)

	%InnButton.visible = false
	%InnButton.toggled.connect(_on_inn_pressed)
	%InnButton.button_down.connect($ButtonPressAudioPlayer.play)
	
func _on_exit_pressed():
	if $ButtonPressAudioPlayer.playing and not $ButtonPressAudioPlayer.is_connected("finished", exit):
		$ButtonPressAudioPlayer.finished.connect(exit)
	else:
		exit()

func exit():
	if $ButtonPressAudioPlayer.is_connected("finished", exit):
		$ButtonPressAudioPlayer.finished.disconnect(exit)
	if %ShopButton.button_pressed:
		%ShopButton.set_pressed(false)
	elif %InventoryButton.button_pressed:
		%InventoryButton.set_pressed(false)
	elif %InnButton.button_pressed:
		%InnButton.set_pressed(false)
	else:
		Party.save_party()
		Party.change_scene("res://Scenes/ui/start_screen.tscn")
		GUI.get_node("%Inventory").visible = false
		get_tree().paused = false
		%InventoryButton.set_pressed_no_signal(false)
		%ShopButton.set_pressed_no_signal(false)
	
func _on_gear_pressed(toggled):
	if $ButtonPressAudioPlayer.playing and not $ButtonPressAudioPlayer.is_connected("finished", gear):
		$ButtonPressAudioPlayer.finished.connect(gear)
	else:
		gear()

var cached_selection = []
func gear():
	if $ButtonPressAudioPlayer.is_connected("finished", gear):
		$ButtonPressAudioPlayer.finished.disconnect(gear)
	if %InventoryButton.button_pressed:
		cached_selection = Party.get_selected_players()
		Party.select_one_member(Party.party_leader)
		for node in get_tree().get_nodes_in_group("Inventory"):
			if node.has_method("refresh"):
				node.refresh()
				
		GUI.get_node("%Inventory").visible = true
		get_tree().paused = true
		%CameraButton.visible = false
	else:
		if not cached_selection.is_empty():
			Party.set_selected_players(cached_selection)
		GUI.get_node("%Inventory").visible = false
		get_tree().paused = false
		%CameraButton.visible = true
#		get_tree().current_scene.process_mode = Node.PROCESS_MODE_ALWAYS

func _on_shop_pressed(toggled):
	if $ButtonPressAudioPlayer.playing:
		$ButtonPressAudioPlayer.finished.connect(shop)
	else:
		shop()

func shop():
	if $ButtonPressAudioPlayer.is_connected("finished", shop):
		$ButtonPressAudioPlayer.finished.disconnect(shop)
	if %ShopButton.button_pressed:
		cached_selection = Party.get_selected_players()
		Party.select_one_member(Party.party_leader)
		for node in get_tree().get_nodes_in_group("Inventory"):
			if node.has_method("refresh"):
				node.refresh()
		get_tree().paused = true
		GUI.get_node("%Shop").visible = true
		%InventoryButton.visible = false
		%CameraButton.visible = false
	else:
		if not cached_selection.is_empty():
			Party.set_selected_players(cached_selection)
		GUI.get_node("%Shop").visible = false
		get_tree().paused = false
		%InventoryButton.visible = true
		%CameraButton.visible = true

func _on_inn_pressed(toggled):
	if $ButtonPressAudioPlayer.playing:
		$ButtonPressAudioPlayer.finished.connect(inn)
	else:
		inn()

func inn():
	if $ButtonPressAudioPlayer.is_connected("finished", inn):
		$ButtonPressAudioPlayer.finished.disconnect(inn)
	if %InnButton.button_pressed:
		cached_selection = Party.get_selected_players()
		Party.select_one_member(Party.party_leader)
		for node in get_tree().get_nodes_in_group("Inventory"):
			if node.has_method("refresh"):
				node.refresh()
		get_tree().paused = true
		GUI.get_node("%Inn").visible = true
		%InventoryButton.visible = false
		%CameraButton.visible = false
	else:
		if not cached_selection.is_empty():
			Party.set_selected_players(cached_selection)
		GUI.get_node("%Inn").visible = false
		get_tree().paused = false
		%InventoryButton.visible = true
		%CameraButton.visible = true

func camera(toggled):
	Party.lock_camera = toggled
