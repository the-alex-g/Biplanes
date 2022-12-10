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
	var m_event := InputEventJoypadMotion.new()
	m_event.device = player_index
	m_event.axis = JOY_AXIS_2
	m_event.axis_value = -1.0
	InputMap.action_add_event("roll_right" + player_id_tag, m_event)
	
	m_event = InputEventJoypadMotion.new()
	m_event.device = player_index
	m_event.axis = JOY_AXIS_2
	m_event.axis_value = 1.0
	InputMap.action_add_event("roll_left" + player_id_tag, m_event)
	
	m_event = InputEventJoypadMotion.new()
	m_event.device = player_index
	m_event.axis = JOY_AXIS_0
	m_event.axis_value = 1.0
	InputMap.action_add_event("right" + player_id_tag, m_event)
	
	m_event = InputEventJoypadMotion.new()
	m_event.device = player_index
	m_event.axis = JOY_AXIS_0
	m_event.axis_value = -1.0
	InputMap.action_add_event("left" + player_id_tag, m_event)
	
	m_event = InputEventJoypadMotion.new()
	m_event.device = player_index
	m_event.axis = JOY_AXIS_1
	m_event.axis_value = 1.0
	InputMap.action_add_event("down" + player_id_tag, m_event)
	
	m_event = InputEventJoypadMotion.new()
	m_event.device = player_index
	m_event.axis = JOY_AXIS_1
	m_event.axis_value = -1.0
	InputMap.action_add_event("up" + player_id_tag, m_event)
	
	# add all events that use joystick buttons
	var b_event := InputEventJoypadButton.new()
	b_event.device = player_index
	b_event.button_index = JOY_BUTTON_7
	InputMap.action_add_event("thrust" + player_id_tag, b_event)
	
	b_event = InputEventJoypadButton.new()
	b_event.device = player_index
	b_event.button_index = JOY_BUTTON_6
	InputMap.action_add_event("shoot" + player_id_tag, b_event)
