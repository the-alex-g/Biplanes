extends Spatial

signal export_viewport_texture(texture, port)

var players := 0 setget _set_players


func _process(_delta:float)->void:
	_export_viewport_textures()


func add_planes(new_players:int)->void:
	players = new_players
	
	for player_id in players:
		var plane_handler : PlaneHandler = load("res://Plane/PlaneHandler.tscn").instance()
		var viewport : Viewport = get_node("Viewport" + str(player_id))
		viewport.add_child(plane_handler)
		plane_handler.set_deferred("player_id", player_id)
		if players == 2:
			viewport.size = Vector2(502, 590)
		elif players > 2:
			viewport.size = Vector2(502, 290)


func _export_viewport_textures()->void:
	for i in players:
		var viewport : Viewport = get_node("Viewport" + str(i))
		emit_signal("export_viewport_texture", viewport.get_texture(), i)


func _set_players(value:int)->void:
	players = value
	add_planes(value)
