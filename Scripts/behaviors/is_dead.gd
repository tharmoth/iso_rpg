extends ConditionLeaf

func tick(actor: Node, _blackboard: Blackboard) -> int:
	if actor.health <= 0:
		return SUCCESS
	else:
		return FAILURE
