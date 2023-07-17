extends Interactable

var radius = 100
@export var target_scene := "res://Scenes/levels/city.tscn"

func _ready():
	super()
	var click_detection_circle = CircleShape2D.new()
	click_detection_circle.radius = radius
	$CollisionShape2D.set_shape(click_detection_circle)

func interact():
	Party.change_scene(target_scene)
