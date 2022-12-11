class_name PlaneHandler
extends Spatial

signal update_pilot_view(texture)
signal update_altitude(value)
signal update_fuel(value)
signal update_ammo(value)
signal update_health(value)

export var camera_distance_from_plane := 50.0
export var camera_vertical_offset := 15.0

onready var _camera : Camera = $MainCamera
onready var _plane = $PilotViewport/Biplane
onready var _pilot_viewport : Viewport = $PilotViewport

var plane_position : Vector3 setget ,_get_plane_position
var player_id : int setget _set_player_id


func _process(_delta:float)->void:
	_camera.translation = Vector3(
		_plane.translation.x,
		_plane.translation.y + camera_vertical_offset,
		_plane.translation.z + camera_distance_from_plane
	)
	_camera.rotation.x = -atan(camera_vertical_offset / camera_distance_from_plane)
	emit_signal("update_pilot_view", _pilot_viewport.get_texture())
	emit_signal("update_altitude", _get_plane_position().y)


func _get_plane_position()->Vector3:
	return _plane.global_translation


func _set_player_id(value:int)->void:
	player_id = value
	_plane.set_deferred("player_id", "_" + str(value))


func _on_Biplane_update_fuel(value:float)->void:
	emit_signal("update_fuel", value)


func _on_Biplane_update_ammo(value:float)->void:
	emit_signal("update_ammo", value)


func _on_Biplane_update_health(value:float)->void:
	emit_signal("update_health", value)
