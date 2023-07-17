extends ConditionLeaf

@export var wander_loop_time = RandomNumberGenerator.new().randf_range(2, 4)
@onready var timer = Timer.new()

func _ready():
	timer.wait_time = wander_loop_time
	timer.one_shot = true
	add_child(timer)
	
func tick(actor: Node, _blackboard: Blackboard) -> int:
	if timer.is_stopped():
		timer.wait_time = RandomNumberGenerator.new().randf_range(2, 4)
		timer.start()
		return SUCCESS
	else:
		return FAILURE
