@tool
extends Path2D

func _ready():
	update_line()
	curve.changed.connect(update_line)
	
func update_line():
	$Line2D.points = curve.get_baked_points()
