class_name Biplane
extends KinematicBody

signal update_fuel(value)
signal update_health(value)
signal update_ammo(value)

# turning speed in revolutions per second
export var turn_speed := 1.0
export var roll_speed := 1.5
export var flight_speed := 30.0
export (float, 0.0, 0.9) var lift_factor := 0.25
export var gravity := 7.5
export var accel_factor := 1.6
export var deaccel_factor := 1.2
export var secs_fuel := 60.0
export var ammo := 20
export var max_speed := 45.0
export var reload_time := 0.2
export var gravity_mitigation := 19.0
# damage per shot. Hah.
export var dps := 1.0
export var health := 10.0

var _rotation_inertia := Vector3.ZERO
var _actual_speed := flight_speed
var _can_shoot := true
var player_id := ""

onready var _reload_timer : Timer = $ReloadTimer


func _physics_process(delta:float)->void:
	var yaw := Input.get_axis("right" + player_id, "left" + player_id)
	var pitch := Input.get_axis("up" + player_id, "down" + player_id)
	var roll := Input.get_axis("roll_left" + player_id, "roll_right" + player_id)
	
	if Input.is_action_pressed("thrust" + player_id) and secs_fuel > 0:
		if _actual_speed < max_speed:
			_actual_speed += delta * accel_factor * (max_speed - flight_speed)
	elif _actual_speed > flight_speed:
		_actual_speed -= delta * deaccel_factor * (max_speed - flight_speed) / 2
	
	if Input.is_action_pressed("shoot" + player_id) and _can_shoot and ammo > 0:
		_shoot()
	
	_calculate_rotation_inertia(yaw, pitch, roll, delta)
	
	rotate_object_local(Vector3.UP, _rotation_inertia.x * delta)
	rotate_object_local(Vector3.RIGHT, _rotation_inertia.y * delta)
	rotate_object_local(Vector3.FORWARD, _rotation_inertia.z * delta)
	
	# I don't know why this works, but it does. https://www.reddit.com/r/godot/comments/g4d232/how_to_get_a_kinematicbody_to_move_in_its_local/
	var movement_vector := transform.basis.xform(Vector3(0, lift_factor, -1)) * _actual_speed
	# the gravity mitigation is for ease of flight.
	movement_vector.y -= (gravity - gravity_mitigation)
	
	var collision := move_and_collide(movement_vector * delta)
	if collision != null:
		_death()
	
	if secs_fuel > 0:
		secs_fuel -= delta * _actual_speed / flight_speed
		emit_signal("update_fuel", secs_fuel)
	elif gravity_mitigation > -20:
		gravity_mitigation -= delta * 3
		if rotation.x > -PI/4:
			rotation.x -= delta
		rotation += Vector3(
			 randf() - 0.5,
			 randf() - 0.5,
			 randf() - 0.5
		) * delta * 2


func _calculate_rotation_inertia(yaw:float, pitch:float, roll:float, delta:float)->void:
	var percent_total_speed := _actual_speed / flight_speed
	
	if yaw == 0 and _rotation_inertia.x != 0:
		_rotation_inertia.x -= delta * sign(_rotation_inertia.x) * deaccel_factor
		if abs(_rotation_inertia.x) < 0.05:
			_rotation_inertia.x = 0
	elif yaw != 0 and abs(_rotation_inertia.x) < turn_speed:
		_rotation_inertia.x += yaw * delta * accel_factor * percent_total_speed
	
	if pitch == 0 and _rotation_inertia.y != 0:
		_rotation_inertia.y -= delta * sign(_rotation_inertia.y) * deaccel_factor
		if abs(_rotation_inertia.y) < 0.05:
			_rotation_inertia.y = 0
	elif pitch != 0 and abs(_rotation_inertia.y) < turn_speed:
		_rotation_inertia.y += pitch * delta * accel_factor * percent_total_speed
	
	if roll == 0 and _rotation_inertia.z != 0:
		_rotation_inertia.z -= delta * sign(_rotation_inertia.z) * deaccel_factor * roll_speed / turn_speed * 2
		if abs(_rotation_inertia.z) < 0.05:
			_rotation_inertia.z = 0
	elif roll != 0 and abs(_rotation_inertia.z) < roll_speed:
		_rotation_inertia.z += roll * delta * accel_factor * percent_total_speed * roll_speed / turn_speed


func _shoot()->void:
	_can_shoot = false
	ammo -= 1
	emit_signal("update_ammo", ammo)
	
	for object in $Body/FiringCone.get_overlapping_bodies():
		if object.has_method("damage"):
			object.damage(dps)
	
	_reload_timer.start(reload_time)
	yield(_reload_timer, "timeout")
	_can_shoot = true


func damage(amount:int)->void:
	health -= amount
	if health <= 0:
		_death()
	emit_signal("update_health", health)


func _death()->void:
	secs_fuel = 0
	ammo = 0
	health = 0
	emit_signal("update_ammo", ammo)
	emit_signal("update_fuel", secs_fuel)
	emit_signal("update_health", health)
