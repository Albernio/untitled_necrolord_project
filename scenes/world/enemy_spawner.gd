extends Node3D


# The enemy scene we want to create. PackScene -> scene to instantiate
@export var enemy_scene: PackedScene

@export var spawn_points: Array[Node3D]

func spawn_enemy() -> void:
	if enemy_scene == null:
		return

	if spawn_points.is_empty():
		return

	var spawn_point: Node3D = spawn_points.pick_random()
	var enemy := enemy_scene.instantiate()

	get_parent().add_child(enemy)

	enemy.global_position = spawn_point.global_position

# Testing spawner with a key press
func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("debug_start_wave"):
		spawn_enemy()
