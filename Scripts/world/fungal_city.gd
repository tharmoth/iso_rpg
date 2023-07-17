class_name City extends Node2D

var size = 50
var neighbors = []
var city_distance = 200
var road_distance = city_distance + 100

var growth_per_second = 10
var can_spawn_cities = true

var type = SETTLEMENT_TYPE.FARM
enum SETTLEMENT_TYPE {FARM, VILLAGE, CITY}
var max_farm_pop = 10
var max_village_pop = 50

@export var display_name := "Charlie"
var tick_time = 0
var tick_rate = 1

var population = 10

func _physics_process(delta):
	if can_spawn_cities:
		size += growth_per_second * delta
		if size > 50: 
			_spawn_new_city()
		
	tick_time += delta
	if tick_time > tick_rate:
		tick_time = 0
		var max_pop = 0
		match type:
			SETTLEMENT_TYPE.FARM:
				max_pop = max_farm_pop
			SETTLEMENT_TYPE.VILLAGE:
				max_pop = max_village_pop
			SETTLEMENT_TYPE.CITY:
				max_pop = 100000000000000000
		
		if population < max_pop:
			population = min(int(population * 1.2), max_pop)
		
		if display_name == "Chuck":
			print(str(population) + " " + str(population >= max_pop) + " " + str(_should_upgrade()))
		
		if population == max_pop and _should_upgrade():
			print("upgrade!")
			match type:
				SETTLEMENT_TYPE.FARM:
					type = SETTLEMENT_TYPE.VILLAGE
					print("Ham time!")
					$ZoneOfControl/CollisionShape2D.shape.radius = city_distance * 2
				SETTLEMENT_TYPE.VILLAGE:
					type = SETTLEMENT_TYPE.CITY
					$ZoneOfControl/CollisionShape2D.shape.radius = city_distance * 4
				SETTLEMENT_TYPE.CITY:
					type = SETTLEMENT_TYPE.CITY
					$ZoneOfControl/CollisionShape2D.shape.radius = city_distance * 8
			queue_redraw()
	
func _spawn_new_city():
	var new_city = load("res://Scenes/world/city.tscn").instantiate()
	
	var new_city_position = _find_best_city_location()
	if new_city_position == Vector2.ZERO:
		can_spawn_cities = false
		queue_redraw()
		return
	new_city.position = new_city_position
	new_city.size = 10
	var zoc = CircleShape2D.new()
	zoc.radius = city_distance / 2
	new_city.get_node("ZoneOfControl/CollisionShape2D").shape = zoc
	
	new_city.add_to_group("Settlements")
	add_sibling(new_city)
	size -= 10
	
	# Link Cities
	for neighbor_city in _cities_within_range_of_city(new_city, road_distance):
		new_city.neighbors.append(neighbor_city)
		neighbor_city.neighbors.append(new_city)

func _find_best_city_location() -> Vector2:
	var random_point
	for i in range(0, 50):
		random_point = position + Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized() * 200
		if _valid_location_for_new_city(random_point, city_distance - 1):
			break
		random_point = Vector2.ZERO
	
	return random_point

func _cities_within_range_of_city(origin_city : City, max_distance : int) -> Array:
	var cities = []
	for city in get_tree().get_nodes_in_group("Settlements"):
		if city != origin_city and max_distance > origin_city.position.distance_to(city.position):
			cities.append(city)
	return cities

func _valid_location_for_new_city(point : Vector2, min_distance : int) -> bool:
	for city in get_tree().get_nodes_in_group("Settlements"):
		if min_distance > point.distance_to(city.position):
			return false
	return true


func _should_upgrade():
	var count = 0
	
#	if display_name == "Chuck":
#		print(_cities_within_range_of_city(self, road_distance * 2))
	if type == SETTLEMENT_TYPE.FARM:
		for city in _cities_within_range_of_city(self, city_distance * 2):
			if city.type != SETTLEMENT_TYPE.FARM:
				return false
			if city.type == SETTLEMENT_TYPE.FARM:
				count += 1

	if type == SETTLEMENT_TYPE.VILLAGE:
		for city in _cities_within_range_of_city(self, city_distance * 4):
			if city.type == SETTLEMENT_TYPE.CITY:
				return false
			if city.type == SETTLEMENT_TYPE.VILLAGE:
				count += 1

	if type == SETTLEMENT_TYPE.VILLAGE:
		for city in _cities_within_range_of_city(self, city_distance * 8):
			if city.type == SETTLEMENT_TYPE.VILLAGE:
				count += 1

	return count >= 5

# TODO: Graph search
func _get_neighbors(settlements : Array, current_depth : int, max_depth : int) -> Array:
	for settlement in neighbors:
		if settlement not in settlements:
			settlements.append(settlement)
			if current_depth < max_depth:
				settlements.append_array(_get_neighbors(settlement, current_depth + 1, max_depth))
	return settlements

func _draw():
	var color : Color
	match type:
		SETTLEMENT_TYPE.FARM:
			color = Color.BLUE
#		SETTLEMENT_TYPE.HAMLET:
#			color = Color.RED
		SETTLEMENT_TYPE.VILLAGE:
			color = Color.RED
#		SETTLEMENT_TYPE.TOWN:
#			color = Color.GOLD
		SETTLEMENT_TYPE.CITY:
			color = Color.GREEN
	draw_circle(Vector2.ZERO, size, color)
	for city in neighbors:
		draw_line(Vector2.ZERO, to_local(city.position), Color.SADDLE_BROWN, 5, true)
