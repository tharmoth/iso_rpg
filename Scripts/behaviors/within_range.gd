extends ConditionLeaf

@export var range := 100

func tick(actor: Node, _blackboard: Blackboard) -> int:
	var distance = 0
	if "start_point" in actor:
		distance = actor.position.distance_to(actor.start_point)
		
	if distance > max_distance:
		return SUCCESS
	else:
		return FAILURE
