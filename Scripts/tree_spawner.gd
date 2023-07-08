@tool
extends Area2D

var trees := []

@export var tree_dist := 100 :
	set(value):
		tree_dist = value
		update_trees()
@export var tree_freq := .4 :
	set(value):
		tree_freq = value
		update_trees()
@export var fractal_octaves := 2.0 :
	set(value):
		fractal_octaves = value
		update_trees()
@export var fractal_lacunarity := 0.0 :
	set(value):
		fractal_lacunarity = value
		update_trees()
@export var fractal_gain := 10.0 :
	set(value):
		fractal_gain = value
		update_trees()
@export var frequency := 1.0 :
	set(value):
		frequency = value
		update_trees()

var seed = 0
		
@onready var cached_poly = $CollisionPolygon2D.polygon

func _ready():
	if not Engine.is_editor_hint() and get_parent().get_parent().has_method("get_seed"):
		seed = get_parent().get_parent().seed
		
	var dir = DirAccess.open("res://Scenes/Sprites/trees/")
	for file in dir.get_files():
		trees.append(load("res://Scenes/Sprites/trees/" + file))
	update_trees()
	
func _process(delta):
	if $CollisionPolygon2D.polygon != cached_poly:
		cached_poly = $CollisionPolygon2D.polygon
		update_trees()
			

func update_trees():
	if not is_node_ready():
		return
		
	for tree in get_children():
		if not tree is CollisionPolygon2D and not tree is Sprite2D:
			remove_child(tree)
	
	var noise = FastNoiseLite.new()
	var rng = RandomNumberGenerator.new()
	rng.seed = seed
	
	noise.noise_type = FastNoiseLite.TYPE_SIMPLEX_SMOOTH
	noise.fractal_octaves = fractal_octaves
	noise.fractal_lacunarity = fractal_lacunarity
	noise.fractal_gain = fractal_gain
	noise.frequency = frequency
	noise.seed = seed
	
#	$Sprite2D.texture.noise = noise

	var max_point := -1 * Vector2.INF
	var min_point := Vector2.INF
	for point in $CollisionPolygon2D.polygon:
		if point.x > max_point.x:
			max_point.x = point.x
		if point.y > max_point.y:
			max_point.y = point.y
		if point.x < min_point.x:
			min_point.x = point.x
		if point.y < min_point.y:
			min_point.y = point.y
	
	for x in range(snapped(min_point.x, 100), snapped(max_point.x, 100), tree_dist):
		for y in range(snapped(min_point.y, 100), snapped(max_point.y, 100), tree_dist):
			var point = Vector2(x + rng.randi_range(-tree_dist / 4, tree_dist / 4), y + rng.randi_range(-tree_dist / 4, tree_dist / 4))
			if not Geometry2D.is_point_in_polygon(point, $CollisionPolygon2D.polygon):
				continue
			
			if abs(noise.get_noise_2dv(point)) > tree_freq:
				var tree = trees[rng.randi_range(0, trees.size() - 1)].instantiate()
				tree.position = point
				add_child(tree)
