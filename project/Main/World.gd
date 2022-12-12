extends Spatial

signal export_viewport_texture(texture, port)

var players := 0 setget _set_players
var plane_colors := {}
var _plane_handlers := []


func _process(_delta:float)->void:
	_export_viewport_textures()
	
	for plane_handler_1 in _plane_handlers:
		var points : PoolVector3Array = []
		for plane_handler_2 in _plane_handlers:
			if plane_handler_1.player_id != plane_handler_2.player_id:
				points.append(plane_handler_2.plane_position)
		plane_handler_1.update_radar_points(points)


func add_planes(new_players:int)->void:
	players = new_players
	
	for player_id in players:
		var plane_handler : PlaneHandler = load("res://Plane/PlaneHandler.tscn").instance()
		var viewport : Viewport = get_node("Viewport" + str(player_id))
		
		plane_handler.player_id = player_id
		plane_handler.color = plane_colors[player_id]
		viewport.add_child(plane_handler)
		_plane_handlers.append(plane_handler)
		
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
