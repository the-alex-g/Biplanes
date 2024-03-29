extends Spatial

signal export_viewport_texture(texture, port)

export var half_ground_size := 300
export var ground_height := 50.0
export var max_scenery := 50
export var min_scenery := 40
export var margin := 25

var players := [] setget _set_players
var plane_colors := {}
var _plane_handlers := {}

onready var _ground : StaticBody = $Ground
onready var _ground_mesh : MeshInstance = $Ground/Ground
onready var _ground_collision := $Ground/CollisionShape


func _ready()->void:
	randomize()
	
	_ground_mesh.set("shader_param/noise/noise/seed", randi())
	_ground_mesh.mesh.size = Vector2(half_ground_size, half_ground_size) * 2
	
	var noise := OpenSimplexNoise.new()
	noise.seed = randi()
	_create_ground_collision(noise)
	_create_ground_mesh(noise)
	
	_generate_scenery()
	_spawn_auto_plane()


func _process(_delta:float)->void:
	_export_viewport_textures()
	
	_update_radar_points()


func _update_radar_points()->void:
	for plane_handler_1 in _plane_handlers.values():
		var points : PoolVector3Array = []
		for plane_handler_2 in _plane_handlers.values():
			if plane_handler_1.player_id != plane_handler_2.player_id:
				if plane_handler_2.active:
					points.append(plane_handler_2.plane_position)
		for plane in $AutomatedPlanes.get_children():
			if not plane.dead:
				points.append(plane.global_translation)
		plane_handler_1.update_radar_points(points)


func _create_ground_collision(noise:OpenSimplexNoise)->void:
	var mesh_faces := _ground_mesh.mesh.get_faces()
	var new_faces : PoolVector3Array = []
	for vertex in mesh_faces:
		new_faces.append(Vector3(
			vertex.x,
			noise.get_noise_2d(vertex.x, vertex.z) * ground_height,
			vertex.z
		))
	var shape := ConcavePolygonShape.new()
	shape.set_faces(new_faces)
	_ground_collision.shape = shape


func _create_ground_mesh(noise:OpenSimplexNoise)->void:
	var surface := _ground_mesh.mesh.surface_get_arrays(0)
	var mesh := ArrayMesh.new()
	var new_normals : PoolVector3Array = []
	var new_verticies : PoolVector3Array = []
	for vertex in surface[ArrayMesh.ARRAY_VERTEX]:
		var new_vertex := Vector3(
			vertex.x,
			noise.get_noise_2d(vertex.x, vertex.z) * ground_height,
			vertex.z
		)
		new_verticies.append(new_vertex)
		new_normals.append(new_vertex)
	surface[ArrayMesh.ARRAY_VERTEX] = new_verticies
	surface[ArrayMesh.ARRAY_NORMAL] = new_normals
	
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, surface)
	
	var material := SpatialMaterial.new()
	material.albedo_color = Color.forestgreen
	mesh.surface_set_material(0, material)
	
	_ground_mesh.mesh = mesh


func add_planes(new_players:Array)->void:
	players = new_players
	
	for i in players.size():
		var player_id : int = players[i]
		
		var plane_handler : PlaneHandler = load("res://Plane/PlaneHandler.tscn").instance()
		var viewport : Viewport = get_node("ViewportContainer/Viewport" + str(i))
		
		plane_handler.player_id = player_id
		plane_handler.color = plane_colors[player_id]
		plane_handler.board_size = half_ground_size
		plane_handler.players = players.size()
		# warning-ignore:return_value_discarded
		plane_handler.connect("plane_down", self, "_on_plane_down")
		viewport.add_child(plane_handler)
		_plane_handlers[player_id] = plane_handler
		
		if players.size() == 2:
			viewport.size = Vector2(502, 590)
		elif players.size() > 2:
			viewport.size = Vector2(502, 290)


func _export_viewport_textures()->void:
	for player_id in players.size():
		var viewport : Viewport = get_node("ViewportContainer/Viewport" + str(player_id))
		emit_signal("export_viewport_texture", viewport.get_texture(), player_id)


func _set_players(value:Array)->void:
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


func _on_plane_down(plane_id:int, killer_id:int, auto_plane := false)->void:
	if killer_id > -1 and plane_id > -1:
		_plane_handlers[killer_id].score(plane_colors[plane_id])
	elif killer_id > -1:
		_plane_handlers[killer_id].score(Color(0.5, 0.5, 0.5, 1.0))
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

