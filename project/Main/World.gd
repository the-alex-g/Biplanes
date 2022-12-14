extends Spatial

signal export_viewport_texture(texture, port)

export var half_ground_size := 300
export var max_scenery := 50
export var min_scenery := 40
export var margin := 25

var players := 0 setget _set_players
var plane_colors := {}
var _plane_handlers := []

onready var _ground := $Ground
onready var _ground_mesh := $Ground/CSGBox
onready var _ground_collision := $Ground/CollisionShape


func _ready()->void:
	randomize()
	_ground_collision.shape.extents = Vector3(half_ground_size, 0.005, half_ground_size)
	_ground_mesh.width = half_ground_size * 2
	_ground_mesh.depth = half_ground_size * 2
	_generate_scenery()
	_spawn_auto_plane()


func _process(_delta:float)->void:
	_export_viewport_textures()
	
	for plane_handler_1 in _plane_handlers:
		var points : PoolVector3Array = []
		for plane_handler_2 in _plane_handlers:
			if plane_handler_1.player_id != plane_handler_2.player_id:
				if plane_handler_2.active:
					points.append(plane_handler_2.plane_position)
		for plane in $AutomatedPlanes.get_children():
			if not plane.dead:
				points.append(plane.global_translation)
		plane_handler_1.update_radar_points(points)


func add_planes(new_players:int)->void:
	players = new_players
	
	for player_id in players:
		var plane_handler : PlaneHandler = load("res://Plane/PlaneHandler.tscn").instance()
		var viewport : Viewport = get_node("ViewportContainer/Viewport" + str(player_id))
		
		plane_handler.player_id = player_id
		plane_handler.color = plane_colors[player_id]
		plane_handler.board_size = half_ground_size
		plane_handler.players = players
# warning-ignore:return_value_discarded
		plane_handler.connect("plane_down", self, "_on_plane_down")
		viewport.add_child(plane_handler)
		_plane_handlers.append(plane_handler)
		
		if players == 2:
			viewport.size = Vector2(502, 590)
		elif players > 2:
			viewport.size = Vector2(502, 290)


func _export_viewport_textures()->void:
	for i in players:
		var viewport : Viewport = get_node("ViewportContainer/Viewport" + str(i))
		emit_signal("export_viewport_texture", viewport.get_texture(), i)


func _set_players(value:int)->void:
	players = value
	add_planes(value)


func _generate_scenery()->void:
	var scenery := floor(lerp(min_scenery, max_scenery, randf()))
	for i in scenery:
		var piece : StaticBody = preload("res://Main/Scenery/Scenery.tscn").instance()
		piece.translation = Vector3(
			lerp(-(half_ground_size - margin), half_ground_size - margin, randf()),
			0,
			lerp(-(half_ground_size - margin), half_ground_size - margin, randf())
		)
		_ground.add_child(piece)


func _on_plane_down(killer_id:int, auto_plane := false)->void:
	if killer_id > -1:
		_plane_handlers[killer_id].score()
	if auto_plane:
		_spawn_auto_plane()


func _spawn_auto_plane()->void:
	var plane := preload("res://Plane/AutomatedPlane/AutomatedPlane.tscn").instance()
	# warning-ignore:return_value_discarded
	plane.connect("dead", self, "_on_plane_down", [true], CONNECT_ONESHOT)
	var plane_position := Vector3(lerp(-(half_ground_size - 10), half_ground_size - 10, randf()), lerp(50, 250, randf()), -(half_ground_size - 10))
	var plane_direction := (randi() % 4) * TAU / 4
	plane.translation = plane_position.rotated(Vector3.UP, plane_direction)
	plane.direction = plane_direction + lerp(-PI/3, PI/3, randf()) + PI
	$AutomatedPlanes.add_child(plane)
