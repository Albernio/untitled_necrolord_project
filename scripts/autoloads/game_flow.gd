extends Node

signal phase_changed(previous_phase: int, new_phase: int)

enum Phase {
	BOOT, #the game has just launched
	NIGHT, #building and repair phase
	SIEGE, #active combat
	RESURRECTING, #the Necrolord is dead temporarily
	RESULT #victory or defeat
}

var current_phase: Phase = Phase.BOOT


func change_phase(new_phase: Phase) -> void:
	if new_phase == current_phase:
		return

	var previous_phase := current_phase
	current_phase = new_phase

	phase_changed.emit(previous_phase, current_phase)


func is_phase(phase: Phase) -> bool:
	return current_phase == phase
