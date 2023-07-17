extends Label

func _ready():
	Party.party_leader_changed.connect(func(player): refresh())

func refresh():
	if Party.party_leader.display_name != null:
		text = Party.party_leader.display_name
