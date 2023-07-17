extends Interactable

func loot(player : BCharacter):
	GUI.get_node("%ShopButton").set_pressed(true)
