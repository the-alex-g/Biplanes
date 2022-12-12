extends KinematicBody

var health := 10
var direction : float = PI / 4
var speed := 30.0

export var gravity := 7.5
export var ammo := 20
export var reload_time := 0.2
export var gravity_mitigation := 7.5
# damage per shot. Hah.
export var dps := 1.0


func _physics_process(delta:float)->void:
	if not $Body.visible:
		return
	
	var movement_vector := Vector3.FORWARD.rotated(Vector3.UP, direction) * speed
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


func damage(amount:int)->void:
	health -= amount
	if health <= 0:
		death()


func death(explode := false)->void:
	health = 0
	gravity_mitigation = 0
	
	if explode:
		$Body.visible = false
		$ExplosionParticles.emitting = true
		yield(get_tree().create_timer($ExplosionParticles.lifetime), "timeout")
		queue_free()
