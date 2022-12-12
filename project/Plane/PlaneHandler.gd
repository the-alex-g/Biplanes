class_name PlaneHandler
extends Spatial

signal update_pilot_view(texture)
signal update_altitude(value)
signal update_fuel(value)
signal update_ammo(value)
signal update_health(value)
signal update_radar(from, points)

export var camera_distance_from_plane := 50.0
export var camera_vertical_offset := 15.0

onready var _camera : Camera = $Viewport/MainCamera
onready var _plane = $Biplane
onready var _pilot_viewport : Viewport = $Viewport

var plane_position : Vector3 setget ,_get_plane_position
var player_id : int
var color : Color
var players : int
var board_size : float
var active := true


func _ready()->void:
	_plane.translation = (Vector3.RIGHT * (board_size - 10) / 2).rotated(Vector3.UP, player_id * TAU / players)
	_plane.translation.y = 50
	_plane.rotation.y = player_id * TAU / players + PI / 2
	_plane.player_id = "_" + str(player_id)
	_plane.color = color


func _process(_delta:float)->void:
	_camera.translation = Vector3(
		_plane.translation.x,
		_plane.translation.y + camera_vertical_offset,
		_plane.translation.z + camera_distance_from_plane
	)
	_camera.rotation.x = -atan(camera_vertical_offset / camera_distance_from_plane)
	emit_signal("update_pilot_view", _pilot_viewport.get_texture())
	emit_signal("update_altitude", _get_plane_position().y)


func _to_vec2(from:Vector3)->Vector2:
	return Vector2(
		from.z,
		from.x
	)


func _get_plane_position()->Vector3:
	return _plane.global_translation


func _on_Biplane_update_fuel(value:float)->void:
	emit_signal("update_fuel", value)


func _on_Biplane_update_ammo(value:float)->void:
	emit_signal("update_ammo", value)


func _on_Biplane_update_health(value:float)->void:
	emit_signal("update_health", value)
	if value <= 0:
		active = false


func update_radar_points(points:PoolVector3Array)->void:
	var flat_points : PoolVector2Array = []
	for point in points:
		var q = _to_vec2(point)
		flat_points.append(q)
	var q = _to_vec2(_plane.get_forward())
	q.y *= -1
	emit_signal("update_radar", _to_vec2(_get_plane_position()), q.angle(), flat_points)
