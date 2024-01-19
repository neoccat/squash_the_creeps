extends CharacterBody3D

@export var speed = 14
@export var fall_acceleration = 150
@export var jump_impulse = 150
@export var bounce_impulse = 100
signal hit

var target_velocity = Vector3.ZERO

func _ready():
	pass # Replace with function body.

func _physics_process(delta):
	handle_mouvement(delta)

func handle_mouvement(delta):
	var direction = Vector3.ZERO
	if Input.is_action_pressed("move_left"):
		direction.x += -1
	if Input.is_action_pressed("move_right"):
		direction.x += 1
	if Input.is_action_pressed("move_forward"):
		direction.z += -1
	if Input.is_action_pressed("move_back"):
		direction.z += 1
	if direction != Vector3.ZERO:
		direction = direction.normalized()
		$Pivot.look_at(position + direction, Vector3.UP)
	
	target_velocity.x = direction.x * speed
	target_velocity.z = direction.z * speed

	if not is_on_floor():
		target_velocity.y = direction.y - (fall_acceleration * delta)
		
	if is_on_floor() and Input.is_action_pressed("jump"):
		target_velocity.y = jump_impulse
		$AnimationPlayer.play("jump")
		await get_tree().create_timer(0.6).timeout
		$AnimationPlayer.play("float")
	
	if direction != Vector3.ZERO:
		$AnimationPlayer.speed_scale = 4
	else:
		$AnimationPlayer.speed_scale = 1
	
	velocity = target_velocity
	move_and_slide()
	
	for index in range(get_slide_collision_count()):
		# We get one of the collisions with the player
		var collision = get_slide_collision(index)

		# If the collision is with ground
		if collision.get_collider() == null:
			continue

		# If the collider is with a mob
		if collision.get_collider().is_in_group("mob"):
			var mob = collision.get_collider()
			# we check that we are hitting it from above.
			if Vector3.UP.dot(collision.get_normal()) > 0.1:
				# If so, we squash it and bounce.
				mob.squash()
				target_velocity.y = bounce_impulse
				# Prevent further duplicate calls.
				break

func die():
	hit.emit()
	queue_free()

func _on_mob_detector_body_entered(body):
	die()
