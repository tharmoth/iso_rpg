extends ActionLeaf

@export var focus : ActionLeaf = null


func tick(actor: Node, blackboard: Blackboard) -> int:
	if focus == null:
		return FAILURE

	actor.target = focus.character

	if actor.animation_current == "Attack":
		return RUNNING

	if actor.attack():
		return RUNNING
	else:
		return FAILURE
