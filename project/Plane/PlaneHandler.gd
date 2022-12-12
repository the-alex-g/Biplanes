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


func _ready()->void:
	_plane.translation.x = 15 * player_id
	_plane.player_id = "_" + str(player_id)


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


func update_radar_points(points:PoolVector3Array)->void:
	var flat_points : PoolVector2Array = []
	for point in points:
		flat_points.append(_to_vec2(point))
	emit_signal("update_radar", _to_vec2(_get_plane_position()), _to_vec2(_plane.get_forward()).angle(), flat_points)
