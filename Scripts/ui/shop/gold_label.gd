extends Label

func _ready():
	Party.gold_changed.connect(refresh)
	refresh()

func refresh():
	text = str(Party.gold)
