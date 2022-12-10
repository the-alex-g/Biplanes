extends Spatial

signal update_pilot_view(texture)

export var camera_distance_from_plane := 10
export var camera_vertical_offset := -1

onready var _camera : Camera = $MainCamera
onready var _plane = $PilotViewport/Biplane
onready var _pilot_viewport : Viewport = $PilotViewport


func _process(_delta:float)->void:
	_camera.translation = Vector3(
		_plane.translation.x,
		_plane.translation.y + camera_vertical_offset,
		_plane.translation.z + camera_distance_from_plane
	)
	emit_signal("update_pilot_view", _pilot_viewport.get_texture())
