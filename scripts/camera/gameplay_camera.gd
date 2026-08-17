extends Camera3D

@export var target: Node3D
@export var offset := Vector3(0.0, 10.0, 10.0)


func _process(_delta: float) -> void:
	if target == null:
		return

	global_position = target.global_position + offset