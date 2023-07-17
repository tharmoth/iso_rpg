extends ActionLeaf

var timer = Timer.new()
@export var wait_time := 3.0

func _ready():
	add_child(timer)

func before_run(actor: Node, blackboard: Blackboard) -> void:
	timer.wait_time = wait_time
	timer.one_shot = true
	timer.start()
	
	actor.target = null
	
func after_run(actor: Node, blackboard: Blackboard) -> void:
	timer.stop()

func tick(actor: Node, blackboard: Blackboard) -> int:
	if not timer.is_stopped():
		return RUNNING
	else:
		return SUCCESS
