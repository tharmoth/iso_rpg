extends Control

var rest_price = 5

var recruit_price = 1000

func _ready():
	%RestButton.pressed.connect(_on_rest_pressed)
	%RestButton.pressed.connect(%MoneyPlayer.play)
	%RestButton.button_down.connect(%ButtonPressAudioPlayer.play)
	Party.gold_changed.connect(update_buttons)
	
func _on_rest_pressed():
	if %ButtonPressAudioPlayer.playing:
		%ButtonPressAudioPlayer.finished.connect(rest)
	else:
		rest()

func rest():
	if $ButtonPressAudioPlayer.is_connected("finished", rest):
		%ButtonPressAudioPlayer.finished.disconnect(rest)
		
	Party.gold -= rest_price
	for player in Party.players:
		player.rest()

func update_buttons():
	%RestButton.disabled = rest_price > Party.gold
	%RecruitButton.disabled = recruit_price > Party.gold
