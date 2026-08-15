extends Node3D

func _ready() -> void:
	GameFlow.change_phase(GameFlow.Phase.SIEGE)

	if GameFlow.is_phase(GameFlow.Phase.SIEGE):
		print("Combat is active")
