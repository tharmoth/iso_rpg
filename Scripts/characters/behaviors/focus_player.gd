extends ActionLeaf

var location : Vector2
var character : Player

func tick(actor: Node, blackboard: Blackboard) -> int:	
	character = null
	var min_dist = INF
	for player in Party.players:
		var distance = actor.position.distance_to(player.position)
		if distance < min_dist and player.alive:
			min_dist = distance
			character = player
	
	if character == null:
		return FAILURE
		
	location = character.position
	if location == null:
		return FAILURE
	return SUCCESS
