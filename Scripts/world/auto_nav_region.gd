extends Node2D

func _ready():
#	var new_2d_region_rid: RID = NavigationServer2D.region_create()
#
#	var default_2d_map_rid: RID = get_world_2d().get_navigation_map()
#	NavigationServer2D.region_set_map(new_2d_region_rid, default_2d_map_rid)	
	
#	var new_navigation_polygon: NavigationPolygon = NavigationPolygon.new()
#
#	navigation_polygon.add_outline($HeightMap.polygon)
#	navigation_polygon.make_polygons_from_outlines()
#	NavigationServer2D.region_set_navigation_polygon(new_2d_region_rid, new_navigation_polygon)


	var new_2d_region_rid: RID = NavigationServer2D.region_create()

	var default_2d_map_rid: RID = get_world_2d().get_navigation_map()
	NavigationServer2D.region_set_map(new_2d_region_rid, default_2d_map_rid)

	var new_navigation_polygon: NavigationPolygon = NavigationPolygon.new()
	var new_outline: PackedVector2Array = PackedVector2Array([
		Vector2(0.0, 0.0),
		Vector2(50.0, 0.0),
		Vector2(50.0, 50.0),
		Vector2(0.0, 50.0),
	])
	new_navigation_polygon.add_outline($HeightMap.polygon * $HeightMap.transform)
	new_navigation_polygon.make_polygons_from_outlines()

	NavigationServer2D.region_set_navigation_polygon(new_2d_region_rid, new_navigation_polygon)
