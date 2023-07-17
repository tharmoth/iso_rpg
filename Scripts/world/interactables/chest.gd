extends Interactable

var _container = ItemContainer.new() : 
	set(value):
		if value is Dictionary:
			for i in value.keys():
				_container.set(i, jsonify.godotify(value[i]))
		elif value is ItemContainer:
			_container = value
		else:
			push_error("Tried to assign a non-ItemContainer value to _container!")

var opened = false : 
	set(value):
		opened = value
		$ClosedSprite.visible = not opened
		$OpenSprite.visible = opened

func _ready():
	super()
	opened = opened
	_container.add_item("dagger")
	clicked.connect(wait_to_play)

#Jank incoming
func wait_to_play():
	Party.party_leader.interaction.connect(_interaction_listener)

func _interaction_listener(action):
	match action:
		BCharacter.INTERACTION.INTERACT:
			open()
			Party.party_leader.interaction.disconnect(_interaction_listener)

func open():
	if not opened:
		$OpenPlayer.play()
		$OpenPlayer.finished.connect(func(): opened = true)
		
	
func loot(player : BCharacter):
	Party.looting_inventory = _container
	GUI.get_node("%Loot").visible = true
	GUI.get_node("%Main").visible = false
	Party.party_leader.interaction.connect(_movement_listener)

func _movement_listener(action):
	GUI.get_node("%Loot").visible = false
	GUI.get_node("%Main").visible = true
	Party.party_leader.interaction.disconnect(_movement_listener)
	
func save():
	return {
		# Metadata
		"filename" : get_scene_file_path(),
		"parent" : get_parent().get_path(),

		# Stats
		"position" : jsonify.jsonify(position),
		
		"_container" : _container.save(),
		"opened" : opened
	}
