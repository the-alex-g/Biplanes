extends TextureRect

signal player_joined(id)
signal player_ready
signal player_not_ready
signal player_left(id)
signal change_color(direction, id)

const BUTTON_MAPS := {"A":JOY_BUTTON_0, "B":JOY_BUTTON_1, "LEFT_SHOULDER":4, "RIGHT_SHOULDER":5}

export var ready := true
export var id := 0

var color := Color(0,0,0,0) setget _set_color
var _joined := false


func _input(event:InputEvent)->void:
	if event is InputEventJoypadButton:
		if event.device == id:
			if event.pressed:
				match event.button_index:
					BUTTON_MAPS.A:
						if not _joined:
							_joined = true
							ready = false
							emit_signal("player_joined", id)
						else:
							ready = true
							emit_signal("player_ready")
					BUTTON_MAPS.B:
						if _joined and not ready:
							_joined = false
							ready = true
							emit_signal("player_left", id)
						elif _joined and ready:
							ready = false
							emit_signal("player_not_ready")
					BUTTON_MAPS.LEFT_SHOULDER:
						emit_signal("change_color", -1, id)
					BUTTON_MAPS.RIGHT_SHOULDER:
						emit_signal("change_color", 1, id)


func _set_color(value:Color)->void:
	modulate = value
	color = value
