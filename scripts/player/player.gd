extends CharacterBody3D

# Maximum movement speed of the Necrolord.
@export var move_speed: float = 15.0

# How quickly the character turns toward its movement direction.
@export var rotation_speed: float = 10.0

@onready var animation_tree: AnimationTree = $AnimationTree

@onready var animation_state: AnimationNodeStateMachinePlayback = \
	animation_tree.get("parameters/playback")

# Attack Variables
@onready var melee_area: Area3D = $MeleeArea

@export var melee_damage: float = 25.0
@export var melee_knockback: float = 12.0
@export var melee_cooldown: float = 0.6

var can_melee: bool = true

func _ready() -> void:
	animation_tree.active = true
	animation_state.start("Idle")

	
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
		velocity.x = target_velocity.x
		velocity.z = target_velocity.z

		#Animation trigger
		animation_state.travel("Run_Attack")

	# Decelerate when the player releases the controls.
	else:
		velocity.x = target_velocity.x
		velocity.z = target_velocity.z

		#Animation trigger
		animation_state.travel("Idle")

	# Only rotate while we have movement input.
	if move_direction != Vector3.ZERO:
		var target_angle := atan2(move_direction.x, move_direction.z)

		rotation.y = lerp_angle(
			rotation.y,
			target_angle,
			rotation_speed * delta
		)
		
	move_and_slide()
	melee_attack()


func melee_attack() -> void:
	if not can_melee:
		return

	can_melee = false

	# Get everything currently inside the melee radius.
	var targets := melee_area.get_overlapping_bodies()

	for target in targets:
		if target.has_method("take_melee_hit"):
			hit_enemy(target)

	# Temporary cooldown.
	await get_tree().create_timer(melee_cooldown).timeout

	can_melee = true

func hit_enemy(enemy: Node3D) -> void:
	# Direction naturally pointing away from the player.
	var away_direction := enemy.global_position - global_position
	away_direction.y = 0.0
	away_direction = away_direction.normalized()

	# Add some randomness.
	var random_direction := Vector3(
		randf_range(-0.7, 0.7),
		0.0,
		randf_range(-0.7, 0.7)
	)

	var final_direction := (
		away_direction + random_direction
	).normalized()

	enemy.take_melee_hit(
		melee_damage,
		final_direction,
		melee_knockback
	)
