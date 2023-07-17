extends Interactable

func loot(player : BCharacter):
	GUI.get_node("%InnButton").set_pressed(true)
