extends ActionLeaf

var location : Vector2
var character : Player

func tick(actor: Node, blackboard: Blackboard) -> int:
	if GlobalPersistant.player.health <= 0:
		return FAILURE
	character = GlobalPersistant.player
	location = character.position
	if location == null:
		return FAILURE
	return SUCCESS
