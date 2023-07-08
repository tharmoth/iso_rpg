class_name Lootable extends Interactable

enum TEST_ENUM {A, B, C}

@export var item : String
var looted := false :
	set(value):
		looted = value
		visible = not looted

@onready var texture = $Sprite2D.texture.get_path() if $Sprite2D.texture != null else null:
	set(value):
		texture = value
		if texture != null:
			$Sprite2D.texture = load(texture)


@onready var polygon : Array = Array($CollisionPolygon2D.polygon) :
	set(value):
		polygon = value
		$CollisionPolygon2D.polygon = PackedVector2Array(polygon)


func _on_mouse_entered():
	if not looted:
		super()


func _on_mouse_exited():
	if not looted:
		super()


func loot(player : BCharacter):
	GlobalCursor.mouse_exit(self)
	looted = true
	return item


########################################
# Save related functions and variables #
########################################
func save():
	return {
		# Metadata
		"filename" : get_scene_file_path(),
		"parent" : get_parent().get_path(),

		# Stats
		"position" : jsonify.jsonify(position),

		# Equipment
		"item" : item,
		"looted" : looted,
		"polygon" : jsonify.jsonify(polygon),
		"texture" : texture
	}
