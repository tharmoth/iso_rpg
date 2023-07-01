class_name Lootable extends Interactable

enum TEST_ENUM {A, B, C}

@export var item : Items.ITEM_NAME : 
	set(value):
		item = value
		if value == null:
			queue_free()


@onready var polygon : PackedVector2Array = $CollisionPolygon2D.polygon :
	set(value):
		polygon = value
		$CollisionPolygon2D.polygon = polygon

func loot(player : Character):
	queue_free()
	GlobalCursor.mouse_exit(self)
	return Items.items.get(item)


########################################
# Save related functions and variables #
########################################
func save():
	return {
		# Metadata
		"filename" : get_scene_file_path(),
		"parent" : get_parent().get_path(),

		# Stats
		"position_x" : position.x,
		"position_y" : position.y,

		# Equipment
		"item" : item,
		"polygon" : polygon,
	}
