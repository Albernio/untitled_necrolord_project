extends CharacterBody3D


@export var move_speed: float = 8.0
@export var stop_distance: float = 3.0
@onready var animation_player: AnimationPlayer = $VisualPivot/Troll_headhunter/AnimationPlayer

# Knockback Variables after getting hit
var knockback_velocity: Vector3 = Vector3.ZERO
@export var knockback_friction: float = 18.0

# Separation Variables to avoid enemies stacking on top of each other
@onready var separation_area: Area3D = $SeparationArea
@export var separation_strength := 3.0
@export var minimum_separation := 1.5

var target: Node3D

func _ready() -> void:
	target = get_tree().get_first_node_in_group("Player")

	if target == null:
		print("Enemy could not find player")

func _physics_process(_delta: float) -> void:

	if knockback_velocity.length() > 0.1:
		# Enemy is currently being thrown.
		velocity = get_knockback_velocity(_delta)

	else:
		# Normal enemy movement.
		velocity = get_normal_movement()

	move_and_slide()

func get_normal_movement() -> Vector3:

	# If there is no player target, do not move.
	if target == null:
		return Vector3.ZERO


	# Get the direction from this enemy to the player.
	var direction := target.global_position - global_position

	# Ignore vertical movement.
	# We only want movement on the X/Z plane.
	direction.y = 0.0


	# Get the distance to the player.
	var distance := direction.length()


	# Normalize the direction only if it has some length.
	# This prevents errors when the enemy is exactly on top of the target.
	if distance > 0.001:
		direction = direction.normalized()


	# Only move toward the player if we are outside the stopping distance.
	if distance > stop_distance:

		# Calculate how much nearby enemies should push us away.
		var separation := get_separation_force()


		# Combine:
		# 1. Movement toward the player.
		# 2. Movement away from nearby enemies.
		var final_direction := (
			direction
			+ separation * separation_strength
		).normalized()


		# Apply horizontal movement.
		velocity.x = final_direction.x * move_speed
		velocity.z = final_direction.z * move_speed


		# Play running animation while moving.
		animation_player.play_run()

	else:

		# Stop moving when close enough to the player.
		velocity.x = 0.0
		velocity.z = 0.0


		# Play idle animation while stopped.
		animation_player.play_idle()


	# Rotate enemy so it faces toward the player.
	if direction.length_squared() > 0.001:

		var target_angle := atan2(
			direction.x,
			direction.z
		)

		rotation.y = target_angle


	# Return the final movement velocity.
	return velocity	

func get_knockback_velocity(_delta: float) -> Vector3:
	velocity = knockback_velocity

	knockback_velocity = knockback_velocity.move_toward(
		Vector3.ZERO,
		knockback_friction * _delta
	)
	return velocity
	


func take_melee_hit(
	damage: float,
	direction: Vector3,
	force: float
) -> void:

	# Apply damage here.
	# Replace this with your HealthComponent call if you already have one.
	# health -= damage

	# Launch the enemy.
	knockback_velocity = direction * force

func get_separation_force() -> Vector3:

	# This stores the total push-away force
	# created by all nearby enemies.
	var force := Vector3.ZERO


	# Loop through every body currently inside SeparationArea.
	for body in separation_area.get_overlapping_bodies():


		# Ignore this enemy itself.
		if body == self:
			continue


		# Ignore anything that is not part of the "enemies" group.
		if not body.is_in_group("enemies"):
			continue


		# Get the direction pointing AWAY from the nearby enemy.
		var away := global_position - body.global_position


		# Ignore vertical separation.
		away.y = 0.0


		# Measure distance between the two enemies.
		var distance := away.length()


		# If enemies are basically in exactly the same position,
		# skip this calculation to avoid division problems.
		if distance <= 0.001:
			continue


		# Only apply separation if enemies are closer
		# than our desired minimum distance.
		if distance < minimum_separation:


			# Calculate how strong the push should be.
			#
			# At minimum_separation:
			# push_strength = 0
			#
			# Very close together:
			# push_strength approaches 1
			var push_strength := (
				1.0 - distance / minimum_separation
			)


			# Add this enemy's push direction
			# to the total separation force.
			force += away.normalized() * push_strength


	# Return the combined push from all nearby enemies.
	return force
