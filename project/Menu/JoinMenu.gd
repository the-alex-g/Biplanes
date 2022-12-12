extends Control

const COLORS := [
	Color.white,
	Color.forestgreen,
	Color.blue,
	Color.red,
	Color.yellow,
	Color.black,
	Color.peru
]

var _planes_joined := []
var _planes_ready := 0
var _plane_colors := {}

onready var _join_widgets := [
	$HBoxContainer/JoinWidget,
	$HBoxContainer/JoinWidget2,
	$HBoxContainer/JoinWidget3,
	$HBoxContainer/JoinWidget4,
]


func _ready()->void:
	for widget in _join_widgets:
		widget.connect("player_joined", self, "_on_plane_joined")
		widget.connect("player_left", self, "_on_plane_left")
		widget.connect("player_ready", self, "_on_plane_ready")
		widget.connect("player_not_ready", self, "_on_plane_not_ready")
		widget.connect("change_color", self, "_on_plane_change_color")


func _input(event:InputEvent)->void:
	if event is InputEventJoypadButton and event.is_pressed():
		if event.button_index == 0 and _planes_joined.size() == _planes_ready and _planes_ready > 0:
			var world : Spatial = preload("res://Main/World.tscn").instance()
			get_tree().root.add_child(world)
			world.set_deferred("plane_colors", _plane_colors)
			world.set_deferred("players", _planes_joined.size())
			queue_free()


func _add_player_actions(player_index:int)->void:
	var player_id_tag := "_" + str(player_index)
	
	# add actions with the appropriate names
	InputMap.add_action("roll_right" + player_id_tag)
	InputMap.add_action("roll_left" + player_id_tag)
	InputMap.add_action("right" + player_id_tag)
	InputMap.add_action("left" + player_id_tag)
	InputMap.add_action("up" + player_id_tag)
	InputMap.add_action("down" + player_id_tag)
	InputMap.add_action("thrust" + player_id_tag)
	InputMap.add_action("shoot" + player_id_tag)
	
	# add all events that use joystick motion
	_add_joy_motion_event(player_index, JOY_AXIS_2, 1.0, "roll_right" + player_id_tag)
	_add_joy_motion_event(player_index, JOY_AXIS_2, -1.0, "roll_left" + player_id_tag)
	
	_add_joy_motion_event(player_index, JOY_AXIS_0, 1.0, "right" + player_id_tag)
	_add_joy_motion_event(player_index, JOY_AXIS_0, -1.0, "left" + player_id_tag)
	
	_add_joy_motion_event(player_index, JOY_AXIS_1, 1.0, "down" + player_id_tag)
	_add_joy_motion_event(player_index, JOY_AXIS_1, -1.0, "up" + player_id_tag)
	
	# add all events that use joystick buttons
	_add_joy_button_event(player_index, JOY_BUTTON_7, "thrust" + player_id_tag)
	_add_joy_button_event(player_index, JOY_BUTTON_6, "shoot" + player_id_tag)


func _add_joy_motion_event(device:int, axis:int, axis_value:float, action:String)->void:
	var event := InputEventJoypadMotion.new()
	event.device = device
	event.axis = axis
	event.axis_value = axis_value
	InputMap.action_add_event(action, event)


func _add_joy_button_event(device:int, button:int, action:String)->void:
	var event := InputEventJoypadButton.new()
	event.device = device
	event.button_index = button
	InputMap.action_add_event(action, event)


func _on_plane_joined(id:int)->void:
	_planes_joined.append(id)
	_plane_colors[id] = _get_unused_color()
	_join_widgets[id].color = _plane_colors[id]
	_add_player_actions(id)


func _on_plane_left(id:int)->void:
	_planes_joined.erase(id)
	_join_widgets[id].color = Color(0,0,0,0)


func _on_plane_ready()->void:
	_planes_ready += 1


func _on_plane_not_ready()->void:
	_planes_ready -= 1


func _on_plane_change_color(direction:int, id:int)->void:
	_plane_colors[id] = _get_unused_color(direction, id)
	_join_widgets[id].color = _plane_colors[id]


func _get_unused_color(direction := 0, id := -1)->Color:
	var final_color : Color
	var used_colors := _plane_colors.values()
	
	if direction == 0:
		for color in COLORS:
			if not used_colors.has(color):
				final_color = color
				break
	else:
		var index : int = COLORS.find(_plane_colors[id])
		while used_colors.has(COLORS[index]):
			index += direction
			index %= COLORS.size()
		final_color = COLORS[index]
	
	return final_color
