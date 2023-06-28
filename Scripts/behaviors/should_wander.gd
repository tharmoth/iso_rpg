extends ConditionLeaf

@export var wander_loop_time = 3.0
@onready var timer = Timer.new()

func _ready():
	timer.wait_time = wander_loop_time
	timer.one_shot = true
	add_child(timer)
	
func tick(actor: Node, _blackboard: Blackboard) -> int:
	if timer.is_stopped():
		timer.start()
		return SUCCESS
	else:
		return FAILURE
