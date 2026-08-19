extends AnimationPlayer

func play_run() -> void:
	play("ShamanRig|Shaman_Run")


func play_idle() -> void:
	play("ShamanRig|Shaman_Stand1")

func play_attack() -> void:
	play("ShamanRig|Shaman_Attack1")