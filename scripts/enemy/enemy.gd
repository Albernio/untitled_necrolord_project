extends CharacterBody3D


@export var move_speed: float = 8.0
@export var stop_distance: float = 3.0
@onready var animation_player: AnimationPlayer = $VisualPivot/Troll_headhunter/AnimationPlayer

var target: Node3D

func _ready() -> void:
	target = get_tree().get_first_node_in_group("Player")

	if target == null:
		print("Enemy could not find player")

func _physics_process(_delta: float) -> void:
	if target == null:
		return
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

	move_and_slide()
