extends ConditionLeaf

@export var focus : ActionLeaf = null

func tick(actor: Node, _blackboard: Blackboard) -> int:
	if focus == null:
		return FAILURE

	if actor.cooldown.is_stopped():
		return SUCCESS
	else:
		return FAILURE
