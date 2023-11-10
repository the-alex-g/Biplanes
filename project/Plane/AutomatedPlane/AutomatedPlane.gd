class_name AutoPlane
extends KinematicBody

signal dead(player_id, killer_id)

var health := 1#45
var direction : float = PI / 4
var speed := 25.0
var dead := false
var gravity := 7.5
var gravity_mitigation := 7.5
var _shot_down := false
var _target : Biplane = null

export var ammo := 20
export var reload_time := 0.2
# damage per shot. Hah.
export var dps := 10.0


func _ready()->void:
	rotation.y = direction


func _physics_process(delta:float)->void:
	if not $Body.visible:
		return
	
	var movement_vector := Vector3.FORWARD.rotated(Vector3.UP, rotation.y)
	if _target != null and not dead:
		if _target.global_translation.distance_squared_to(global_translation) > 900:
			if abs(_target.global_translation.y - global_translation.y) > 1.0:
				movement_vector.y = sign(_target.global_translation.y - global_translation.y)
			look_at(_target.global_translation, Vector3.UP)
			rotation.x = 0.0
			rotation.z = 0.0
		else:
			rotation.x = PI / 3
	movement_vector = movement_vector.normalized() * speed
	movement_vector.y -= (gravity - gravity_mitigation)
	
	var collision := move_and_collide(movement_vector * delta)
	
	if collision != null:
		death(true)
		if collision.collider.has_method("death"):
			collision.collider.death(true)
	
	if health <= 0:
		if gravity_mitigation > -20:
			gravity_mitigation -= delta * 3
		
		if rotation.x > -PI/4:
			rotation.x -= delta
		rotation += Vector3(
			 randf() - 0.5,
			 randf() - 0.5,
			 randf() - 0.5
		) * delta * 2


func damage(amount:int, attacker_id:int)->void:
	health -= amount
	if health <= 0:
		_shot_down = true
		death()
		emit_signal("dead", -1, attacker_id)


func death(explode := false)->void:
	if not _shot_down and not dead:
		emit_signal("dead", -1, -1)
	
	dead = true
	$CPUParticles.emitting = true
	
	health = 0
	gravity_mitigation = 0
	
	if explode:
		$Body.visible = false
		$ExplosionParticles.emitting = true
		$CPUParticles.emitting = false
		yield(get_tree().create_timer($CPUParticles.lifetime), "timeout")
		queue_free()


func _on_Area_body_entered(body:PhysicsBody)->void:
	if body is Biplane and _target == null and not dead:
		_target = body
		# warning-ignore:return_value_discarded
		_target.connect("dead", self, "_on_target_dead", [], CONNECT_ONESHOT)


func _on_target_dead(_target_color:Color, _killer_id:int)->void:
	_target = null


func _on_FiringCone_body_exited(body:PhysicsBody)->void:
	if body == _target:
		$ReloadTimer.stop()


func _on_FiringCone_body_entered(body:PhysicsBody)->void:
	if body == _target:
		$ReloadTimer.start(reload_time)


func _on_ReloadTimer_timeout()->void:
	_shoot()


func _shoot()->void:
	for body in $Body/FiringCone.get_overlapping_bodies():
		if body is Biplane:
			body.damage(dps, -1)
