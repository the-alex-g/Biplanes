extends KinematicBody

# turning speed in revolutions per second
export var turn_speed := 0.6
export var flight_speed := 1.0


func _physics_process(delta:float)->void:
	rotation += Vector3(
		Input.get_axis("up", "down"),
		Input.get_axis("right", "left"),
		Input.get_axis("roll_right", "roll_left")
	) * turn_speed * delta
	var direction := Vector3.FORWARD * flight_speed * delta
	direction = direction.rotated(Vector3.UP, rotation.y)
	var _collision := move_and_collide(direction)
