extends KinematicBody

# turning speed in revolutions per second
export var turn_speed := 0.8
export var flight_speed := 2.0
export var lift_factor := 1.0
export var gravity := 2.0


func _physics_process(delta:float)->void:
	rotate_object_local(Vector3.UP, Input.get_axis("right", "left") * turn_speed * delta)
	rotate_object_local(Vector3.RIGHT, Input.get_axis("up", "down") * turn_speed * delta)
	rotate_object_local(Vector3.FORWARD, Input.get_axis("roll_left", "roll_right") * turn_speed * delta)
	
	# I don't know why this works, but it does. https://www.reddit.com/r/godot/comments/g4d232/how_to_get_a_kinematicbody_to_move_in_its_local/
	var movement_vector := transform.basis.xform(Vector3(0, lift_factor, -1)) * flight_speed
	movement_vector.y -= gravity
	
	var _collision := move_and_collide(movement_vector * delta)
