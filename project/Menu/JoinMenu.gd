extends Control

var _planes_joined := []

onready var _planes_joined_label : Label = $PlanesJoined


func _input(event:InputEvent)->void:
	if event is InputEventJoypadButton and event.is_pressed():
		if event.button_index == 0:
			if not _planes_joined.has(event.device):
				_planes_joined.append(event.device)
				_add_player_actions(event.device)
				_planes_joined_label.text = "Players Joined: " + str(_planes_joined.size())
			else:
				var world : Spatial = preload("res://Main/World.tscn").instance()
				get_tree().root.add_child(world)
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
