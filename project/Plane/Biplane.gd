class_name Biplane
extends KinematicBody

signal update_fuel(value)
signal update_health(value)
signal update_ammo(value)
signal dead(killer_id)
signal can_hit(value)

# turning speed in revolutions per second
export var turn_speed := 1.0
export var buffer_zone := 0.05
export var roll_speed := 1.3
export var flight_speed := 30.0
export (float, 0.0, 0.9) var lift_factor := 0.25
export var gravity := 7.5
export var accel_factor := 1.6
export var deaccel_factor := 1.2
export var max_speed := 45.0
export var reload_time := 0.2
export var gravity_mitigation := 0.0
# damage per shot. Hah.
export var dps := 10.0
export var max_health := 60.0
export var max_fuel := 120.0
export var max_ammo := 20
export var gun_range := 100.0 setget _set_range

var _health := 60.0
var _secs_fuel := 120.0
var _ammo := 20
var _rotation_inertia := Vector3.ZERO
var _actual_speed := flight_speed
var _can_shoot := true
var altitude : float setget , _get_altitude
var player_id := ""
var color : Color setget _set_color
var dead := false
var range_finder := false
var advanced_flight := false
var auto_right := false

onready var _reload_timer : Timer = $ReloadTimer
onready var _shoot_player : VariableStreamPlayer = $ShootPlayer


func _physics_process(delta:float)->void:
	if not $Body.visible:
		return
	
	var yaw := Input.get_axis("right" + player_id, "left" + player_id)
	var pitch := Input.get_axis("up" + player_id, "down" + player_id)
	var roll := Input.get_axis("roll_left" + player_id, "roll_right" + player_id)
	
	if Input.is_action_pressed("thrust" + player_id) and _secs_fuel > 0:
		if _actual_speed < max_speed:
			_actual_speed += delta * accel_factor * (max_speed - flight_speed)
	elif _actual_speed > flight_speed:
		_actual_speed -= delta * deaccel_factor * (max_speed - flight_speed) / 2
	
	if Input.is_action_pressed("shoot" + player_id) and _can_shoot and _ammo > 0:
		_shoot()
	
	_calculate_rotation_inertia(yaw, pitch, roll, delta)
	
	if not advanced_flight:
		# up/down
		rotate_object_local(Vector3.RIGHT, _rotation_inertia.y * delta)
		#left/right
		rotation.y += _rotation_inertia.x * delta
	
	else:
		rotate_object_local(Vector3.UP, _rotation_inertia.x * delta)
		rotate_object_local(Vector3.RIGHT, _rotation_inertia.y * delta)
		rotate_object_local(Vector3.FORWARD, _rotation_inertia.z * delta)
	
	# I don't know why this works, but it does. https://www.reddit.com/r/godot/comments/g4d232/how_to_get_a_kinematicbody_to_move_in_its_local/
	var movement_vector := transform.basis.xform(Vector3(0, lift_factor, -1)) * _actual_speed
	# the gravity mitigation is for ease of flight.
	movement_vector.y -= (gravity - gravity_mitigation)
	
	var collision := move_and_collide(movement_vector * delta)
	if collision != null:
		if not collision.collider.is_in_group("Barriers"):
			death(true)
			if collision.collider.has_method("death"):
				collision.collider.death(true)
	if _secs_fuel > 0:
		_secs_fuel -= delta * _actual_speed / flight_speed
		emit_signal("update_fuel", _secs_fuel)
	elif gravity_mitigation > -20:
		gravity_mitigation -= delta * 3
		if rotation.x > -PI/4:
			rotation.x -= delta
		rotation += Vector3(
			 randf() - 0.5,
			 randf() - 0.5,
			 randf() - 0.5
		) * delta * 2
	
	if range_finder:
		emit_signal("can_hit", _check_range())
	
	$GroundDetector.global_rotation = Vector3.ZERO


func _calculate_rotation_inertia(yaw:float, pitch:float, roll:float, delta:float)->void:
	var percent_total_speed := _actual_speed / flight_speed
	
	if yaw == 0 and _rotation_inertia.x != 0:
		_rotation_inertia.x -= delta * sign(_rotation_inertia.x) * deaccel_factor
		if abs(_rotation_inertia.x) < buffer_zone:
			_rotation_inertia.x = 0
	elif yaw != 0 and abs(_rotation_inertia.x) < turn_speed:
		_rotation_inertia.x += yaw * delta * accel_factor * percent_total_speed
	
	if pitch == 0 and _rotation_inertia.y != 0:
		_rotation_inertia.y -= delta * sign(_rotation_inertia.y) * deaccel_factor
		if abs(_rotation_inertia.y) < buffer_zone:
			_rotation_inertia.y = 0
	elif pitch != 0 and abs(_rotation_inertia.y) < turn_speed:
		_rotation_inertia.y += pitch * delta * accel_factor * percent_total_speed
	
	if advanced_flight:
		if roll == 0 and (_rotation_inertia.z != 0 or (auto_right and abs(rotation.z) > buffer_zone and yaw == 0)): # if not rolling
			if auto_right and abs(rotation.z) > buffer_zone and abs(_rotation_inertia.z) < roll_speed: # speed up in order to right plane
				_rotation_inertia.z += delta * sign(rotation.z) * roll_speed
			
			else: # slow down that rolling
				_rotation_inertia.z -= delta * sign(_rotation_inertia.z) * deaccel_factor * roll_speed / turn_speed * 2
				if abs(_rotation_inertia.z) < buffer_zone:
					_rotation_inertia.z = 0
			
			if auto_right and abs(rotation.z) < 0.02: # snap to vertical
				rotation.z = 0.0
		
		elif roll != 0 and abs(_rotation_inertia.z) < roll_speed: # speed up
			_rotation_inertia.z += roll * delta * accel_factor * percent_total_speed * roll_speed / turn_speed


func _check_range()->bool:
	for object in $Body/FiringCone.get_overlapping_bodies():
		if object.has_method("damage"):
			return true
	return false


func _shoot()->void:
	_shoot_player.play()
	_can_shoot = false
	_ammo -= 1
	emit_signal("update_ammo", _ammo)
	
	for object in $Body/FiringCone.get_overlapping_bodies():
		if object.has_method("damage"):
			object.damage(dps, int(player_id[1]))
	
	_reload_timer.start(reload_time)
	yield(_reload_timer, "timeout")
	_can_shoot = true


func damage(amount:int, attacker_id:int)->void:
	_health -= amount
	if _health <= 0:
		dead = true
		death()
		$SmokeParticles.emitting = true
		emit_signal("dead", attacker_id)
	emit_signal("update_health", _health)


func death(explode := false)->void:
	_secs_fuel = 0
	_ammo = 0
	_health = 0
	emit_signal("update_ammo", _ammo)
	emit_signal("update_fuel", _secs_fuel)
	emit_signal("update_health", _health)
	
	if not dead:
		emit_signal("dead", -1)
	dead = true
	
	if explode:
		$Body.visible = false
		$ExplosionParticles.emitting = true
		$SmokeParticles.emitting = false
		$CollisionShape.disabled = true


func get_forward()->Vector3:
	return transform.basis.xform(Vector3(0, 0, -1))


func _set_color(value:Color)->void:
	color = value
	var material := ShaderMaterial.new()
	material.shader = load("res://Plane/stripe_shader.gdshader")
	material.set("shader_param/main_color",Vector3(
		color.r, color.g, color.b))
	var stripe_color := Vector3.ONE - Vector3(color.r, color.g, color.b)
	if stripe_color == Vector3.ONE:
		stripe_color *= 0.99
	material.set("shader_param/fin_color",stripe_color)
	$Body.material = material


func _on_PlaneHandler_upgrade(field_name:String)->void:
	match field_name:
		"speed":
			flight_speed += 10.0
			max_speed = flight_speed * 1.5
			turn_speed *= 1.25
		"fuel":
			max_fuel += 10.0
		"damage":
			dps += 2.0
		"ammo":
			max_ammo += 5
		"reload":
			reload_time *= 0.75
		"health":
			max_health += 5
		"manuverability":
			accel_factor *= 1.25
			deaccel_factor *= 1.25
		"range":
			_set_range(gun_range + 10)
		"targeter":
			range_finder = true
		"advanced_flight":
			advanced_flight = ! advanced_flight
		"auto_right":
			auto_right = true
		"reset":
			_reset_upgrades()


func _reset_upgrades()->void:
	range_finder = false
	advanced_flight = false
	auto_right = false
	flight_speed = 30.0
	turn_speed = 1.0
	max_speed = 45.0
	reload_time = 0.2
	dps = 10.0
	max_health = 60.0
	max_fuel = 120.0
	max_ammo = 20
	_set_range(100.0)
	accel_factor = 1.6
	deaccel_factor = 1.2


func _set_range(value:float)->void:
	gun_range = value
	var spread := gun_range * 0.04
	var shape := [
		Vector3.ZERO,
		Vector3(spread, gun_range, spread),
		Vector3(-spread, gun_range, spread),
		Vector3(-spread, gun_range, -spread),
		Vector3(spread, gun_range, -spread)
	]
	$Body/FiringCone/CollisionShape.shape.points = shape


func _get_altitude()->float:
	var ground_position : Vector3 = $GroundDetector.get_collision_point()
	return global_translation.y - ground_position.y


func restart()->void:
	_actual_speed = flight_speed
	_rotation_inertia = Vector3.ZERO
	gravity_mitigation = 0.0
	lift_factor = gravity / flight_speed
	_health = max_health
	_ammo = max_ammo
	_secs_fuel = max_fuel
	dead = false
	$Body.visible = true
	$CollisionShape.disabled = false
	$SmokeParticles.emitting = false
