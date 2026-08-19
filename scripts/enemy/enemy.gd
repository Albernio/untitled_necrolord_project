extends CharacterBody3D


@export var move_speed: float = 8.0
@export var stop_distance: float = 3.0
@onready var animation_player: AnimationPlayer = $VisualPivot/Troll_headhunter/AnimationPlayer

# Knockback Variables after getting hit
var knockback_velocity: Vector3 = Vector3.ZERO
@export var knockback_friction: float = 18.0

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
	
	if target == null:
		return Vector3.ZERO
	# Direction to the target
	var direction := target.global_position - global_position
	direction.y = 0.0  # Ignore vertical difference for horizontal movement
	direction = direction.normalized() # Normalized direction vector

	velocity.x = direction.x * move_speed
	velocity.z = direction.z * move_speed

	var distance := global_position.distance_to(target.global_position)

	if distance > stop_distance:

		velocity.x = direction.x * move_speed
		velocity.z = direction.z * move_speed
		
		#Animation trigger
		animation_player.play_run()
	else:
		velocity.x = 0.0
		velocity.z = 0.0
		#Animation trigger
		animation_player.play_idle()
		
	# Face the movement direction.
	var target_angle := atan2(direction.x, direction.z)
	rotation.y = target_angle

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
