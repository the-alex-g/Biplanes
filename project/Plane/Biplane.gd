extends KinematicBody

# turning speed in revolutions per second
export var turn_speed := 0.8
export var flight_speed := 2.0
export var lift_factor := 1.0
export var gravity := 2.0
export var accel_factor := 1.5
export var decel_factor := 1.0

var _rotation_inertia := Vector3.ZERO


func _physics_process(delta:float)->void:
	var yaw := Input.get_axis("right", "left")
	var pitch := Input.get_axis("up", "down")
	var roll := Input.get_axis("roll_right", "roll_left")
	
	_calculate_rotation_inertia(yaw, pitch, roll, delta)
	
	rotate_object_local(Vector3.UP, _rotation_inertia.x * delta)
	rotate_object_local(Vector3.RIGHT, _rotation_inertia.y * delta)
	rotate_object_local(Vector3.FORWARD, _rotation_inertia.z * delta)
	
	# I don't know why this works, but it does. https://www.reddit.com/r/godot/comments/g4d232/how_to_get_a_kinematicbody_to_move_in_its_local/
	var movement_vector := transform.basis.xform(Vector3(0, lift_factor, -1)) * flight_speed
	movement_vector.y -= gravity
	
	var _collision := move_and_collide(movement_vector * delta)


func _calculate_rotation_inertia(yaw:float, pitch:float, roll:float, delta:float)->void:
	if yaw == 0 and _rotation_inertia.x != 0:
		_rotation_inertia.x -= delta * sign(_rotation_inertia.x) * decel_factor
		if abs(_rotation_inertia.x) < 0.05:
			_rotation_inertia.x = 0
	elif yaw != 0 and abs(_rotation_inertia.x) < turn_speed:
		_rotation_inertia.x += yaw * delta * accel_factor
	
	if pitch == 0 and _rotation_inertia.y != 0:
		_rotation_inertia.y -= delta * sign(_rotation_inertia.y) * decel_factor
		if abs(_rotation_inertia.y) < 0.05:
			_rotation_inertia.y = 0
	elif pitch != 0 and abs(_rotation_inertia.y) < turn_speed:
		_rotation_inertia.y += pitch * delta * accel_factor
	
	if roll == 0 and _rotation_inertia.z != 0:
		_rotation_inertia.z -= delta * sign(_rotation_inertia.z) * decel_factor
		if abs(_rotation_inertia.z) < 0.05:
			_rotation_inertia.z = 0
	elif roll != 0 and abs(_rotation_inertia.z) < turn_speed:
		_rotation_inertia.z += roll * delta * accel_factor
