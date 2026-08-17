extends CharacterBody3D

# Maximum movement speed of the Necrolord.
@export var move_speed: float = 15.0

# How quickly the player reaches full speed.
@export var acceleration: float = 30.0

# How quickly the player stops when movement input is released.
@export var deceleration: float = 35.0

# How quickly the character turns toward its movement direction.
@export var rotation_speed: float = 10.0

@onready var animation_player: AnimationPlayer = $VisualPivot/ShamanAnimFinal/AnimationPlayer

func _physics_process(delta: float) -> void:
	# Read the four directional input actions.
	var input_vector := Input.get_vector(
		"move_left",
		"move_right",
		"move_up",
		"move_down"
	)

	# Convert Vector2 input into movement along the X/Z ground plane.
	var move_direction := Vector3(input_vector.x, 0.0, input_vector.y)

	var target_velocity := move_direction * move_speed

	# Accelerate while receiving movement input.
	if move_direction != Vector3.ZERO:
		velocity.x = move_toward(
			velocity.x,
			target_velocity.x,
			acceleration * delta
		)

		velocity.z = move_toward(
			velocity.z,
			target_velocity.z,
			acceleration * delta
		)
		#Animation trigger
		animation_player.play_run()

	# Decelerate when the player releases the controls.
	else:
		velocity.x = move_toward(
			velocity.x,
			0.0,
			deceleration * delta
		)

		velocity.z = move_toward(
			velocity.z,
			0.0,
			deceleration * delta
		)

		#Animation trigger
		animation_player.play_idle()

	# Only rotate while we have movement input.
	if move_direction != Vector3.ZERO:
		var target_angle := atan2(move_direction.x, move_direction.z)

		rotation.y = lerp_angle(
			rotation.y,
			target_angle,
			rotation_speed * delta
		)
		
	move_and_slide()
