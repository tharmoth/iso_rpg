extends ConditionLeaf

func tick(actor: Node, _blackboard: Blackboard) -> int:
	if actor.alive:
		return FAILURE
	else:
		return SUCCESS
