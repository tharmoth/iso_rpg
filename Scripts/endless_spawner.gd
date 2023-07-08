extends Area2D

var spawned := false

var to_spawn := load("res://Scenes/levels/road.tscn")

func _ready():
	body_entered.connect(printy)
	
func printy(body):
	if body is Player and not spawned:
		var next_road = to_spawn.instantiate()
		next_road.position = Vector2(-4096, 0)
		spawned = true
		next_road.get_node("AudioStreamPlayer").autoplay = false
		next_road.get_node("Exit").queue_free()
		next_road.seed = RandomNumberGenerator.new().randi()

		get_parent().add_child.call_deferred(next_road)
