extends Node2D

var timer = StepTimer.new(3, 0.125)

func _process(delta: float) -> void:
	timer.process(delta)	
	
	if timer.requires_update:
		update_sprites(timer.current_step)
	elif timer.is_complete:
		timer.complete()
	
func play() -> bool:
	return timer.start()
	
func update_sprites(step: int) -> void:
	match step:
		1:
			$Explosion1.play("default")
		2:
			$Explosion2.play("default")
			$Explosion3.play("default")
		3:
			$Explosion4.play("default")
			$Explosion5.play("default")
