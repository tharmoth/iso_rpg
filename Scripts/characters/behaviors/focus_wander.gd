extends ActionLeaf

@export var wander_distance := 200
var location : Vector2 = Vector2.ZERO

func tick(actor: Node, blackboard: Blackboard) -> int:
	if location == Vector2.ZERO or actor.position.distance_to(location) < 20 or actor.position.distance_to(location) > wander_distance * 1.5:
		location = generate_location(actor)
	return SUCCESS

func generate_location(actor : Node) -> Vector2:
	return actor.position + Vector2(randf_range(-1,1), randf_range(-1,1)).normalized() * wander_distance
