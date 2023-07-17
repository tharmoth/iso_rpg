extends ActionLeaf

@export var focus : ActionLeaf = null

func tick(actor: Node, blackboard: Blackboard) -> int:
	if focus == null:
		return FAILURE
	
	var min_distance = 50
	var distance = actor.position.distance_to(focus.location)
	
	actor.target = focus.location
		
	if distance < min_distance:
		return SUCCESS
	elif actor.navigation_agent.is_navigation_finished():
		return FAILURE
	else:
		return RUNNING
