class_name UTILS extends Node



const HOSTILE_COLOR := Color(.7, .1, .1)
const PLAYER_COLOR := Color(.1, .7, .1)
const SELECTED_COLOR := Color("00FA00")
const HIGHLIGHTED_COLOR := Color(1, 1, 1)

const HAIR_COLORS := [Color("aa8866"), Color("debe99"), Color("241c11"), Color("4f1a00"), Color("9a3300")]

const INFINITY : int = 999999 # for json compat
const MINUS_INFINITY : int = -1 * INFINITY # for json compat
const MALE_NAMES : Array[String] = ["Akibrus",
"Angun",
"Balrus",
"Bulruk",
"Caldor",
"Dagen",
"Darvyn",
"Delvin",
"Dracyian",
"Dray",
"Eldar",
"Engar",
"Fabien",
"Farkas",
"Galdor",
"Igor",
"Jai-Blynn",
"Klayden",
"Laimus",
"Malfas",
"Norok",
"Orion",
"Pindious",
"Quintus",
"Rammir",
"Remus",
"Rorik",
"Sabir" ,
"Séverin",
"Sirius",
"Soril",
"Sulfu",
"Syfas",
"Viktas",
"Vyn",
"Wilkass",
"Yagul",
"Zakkas",
"Zarek",
"Zorion",
]

static func find_closest_ray(rays : Array, ray : Vector2) -> Vector2:
	var maxvalue = 0
	var dir = Vector2.ZERO
	for i in len(rays):
		var value = ray.dot(rays[i])
		if value > maxvalue :
			maxvalue = value
			dir = rays[i]

	return dir
	
static func array_dot(array_one : Array, array_two : Array) -> Array:
	if len(array_one) !=  len(array_two):
		push_error("dot product arrays must be same size!")
	
	var dot_array = []
	dot_array.resize(len(array_one))
	
	for i in len(array_one):
		dot_array[i] = array_one[i] * array_two[i]
	
	return dot_array
	
static func array_sum_vector2(array : Array) -> Vector2:
	var sum := Vector2.ZERO
	for item in array:
		sum += item
	return sum
	
static func clamp_rotation(old_rotation : Vector2, new_rotation : Vector2, clamp_angle_degrees : float) -> Vector2:
	var clamped_rotation = find_closest_ray(cardinal_rays(), new_rotation)	
	if rad_to_deg(abs(old_rotation.angle_to(new_rotation))) > clamp_angle_degrees or old_rotation == Vector2.ZERO:
		return clamped_rotation
	return old_rotation

static func cardinal_rays() -> Array:
	var rays = []
	rays.resize(8)
	for i in 8:
		var angle = i / 8.0 * 2.0 * PI 
		rays[i] = Vector2.RIGHT.rotated(angle)
	return rays
