extends ConditionLeaf

@export var range := 700
@export var focus : ActionLeaf = null

func tick(actor: Node, _blackboard: Blackboard) -> int:
	if focus == null:
		return FAILURE
	
	var distance = actor.position.distance_to(focus.location)
		
	if distance < range:
		return SUCCESS
	else:
		return FAILURE
