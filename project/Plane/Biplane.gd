extends KinematicBody

# turning speed in revolutions per second
export var turn_speed := 0.8
export var flight_speed := 2.0


func _physics_process(delta:float)->void:
	rotate_object_local(Vector3.UP, Input.get_axis("right", "left") * turn_speed * delta)
	rotate_object_local(Vector3.RIGHT, Input.get_axis("up", "down") * turn_speed * delta)
	rotate_object_local(Vector3.FORWARD, Input.get_axis("roll_left", "roll_right") * turn_speed * delta)
	
	var movement_vector := transform.basis.xform(Vector3.FORWARD)
	
	var _collision := move_and_collide(movement_vector * flight_speed * delta)
