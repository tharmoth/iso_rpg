extends CanvasGroup

var icon : String = random_png("res://Assets/ai/Icons/Male/Fighter/") :
	get:
		if jsonify.godotify(get_parent().multisprite.get("icon")) is String and icon != jsonify.godotify(get_parent().multisprite.get("icon")):
			icon = jsonify.godotify(get_parent().multisprite.get("icon"))
		return icon

var hair_color = random(UTILS.HAIR_COLORS) :
	set(value):
		hair_color = value
		$Hair.modulate = hair_color
		$FacialHair.modulate = hair_color
		
var hair_sprite : String = random_png("res://Assets/characters/male/Hair/"):
	set(value):
		hair_sprite = value
		$Hair.texture = load(hair_sprite)
var facial_hair : String = random_png("res://Assets/characters/male/FacialHair/"):
	set(value):
		facial_hair = value
		$FacialHair.texture = load(facial_hair)
var base : String = random_png("res://Assets/characters/male/Base/"):
	set(value):
		base = value
		$Base.texture = load(base)
		
var voice : String = random_scene("res://Scenes/characters/voices/"):
	set(value):
		voice = value
		get_parent().add_child.call_deferred(load(voice).instantiate())
		
var weapon : String = "unarmed" :
	set(value):
		if value == null:
			return
			
		weapon = value
		
		var texture = null
		var texture_path = "res://Assets/characters/male/Weapons/" + weapon + ".png"
		if value != null and ResourceLoader.exists(texture_path):
			texture = load(texture_path)
		$Weapon.texture = texture
var armor : String = "clothing" :
	set(value):
		if value == null:
			return
		armor = value
		
		var top_texture = null
		var bottom_texture = null
		var top_texture_path = "res://Assets/characters/male/Top/" + armor + ".png"
		var bottom_texture_path = "res://Assets/characters/male/Bottom/" + armor + ".png"
		if value != null and ResourceLoader.exists(top_texture_path) and ResourceLoader.exists(bottom_texture_path):
			top_texture = load(top_texture_path)
			bottom_texture = load(bottom_texture_path)
		$Top.texture = top_texture
		$Bottom.texture = bottom_texture
var shield : String = "unarmed_oh" :
	set(value):
		if value == null:
			return
		shield = value
		
		var texture = null
		var texture_path = "res://Assets/characters/male/Weapons/" + shield + ".png"
		if value != null and ResourceLoader.exists(texture_path):
			texture = load(texture_path)
		$Shield.texture = texture


func _ready():
	refresh()


# for the gui pinup
func refresh():
	if "multisprite" in get_parent():
		for i in get_parent().multisprite.keys():
			set(i, jsonify.godotify(get_parent().multisprite[i]))

	#Initalize
	hair_color = hair_color
	hair_sprite = hair_sprite
	facial_hair = facial_hair
	base = base
	weapon = weapon
	armor = armor
	shield = shield
	voice = voice


func get_icon() -> Texture2D:
	return load(icon)


func save():
	return {
		"icon" : icon,
		"hair_color" : jsonify.jsonify(hair_color),
		"hair_sprite" : hair_sprite,
		"facial_hair" : facial_hair,
		"base" : base,
		"voice" : voice,
	}


static func random(list : Array):
	return list[RandomNumberGenerator.new().randi_range(0, list.size() - 1)]

static func random_png(path : String) -> String:
	return random_file(path, ".png")

static func random_scene(path : String) -> String:
	return random_file(path, ".tscn")

static func random_file(path : String, extention : String) -> String:
	var pngs = []
	for file in DirAccess.open(path).get_files():
		if file.ends_with(extention):
			pngs.append(file)
	return path + random(pngs)
