extends ActionLeaf

var location : Vector2

func tick(actor: Node, blackboard: Blackboard) -> int:
	location = actor.start_point
	if location == null:
		return FAILURE
	return SUCCESS
