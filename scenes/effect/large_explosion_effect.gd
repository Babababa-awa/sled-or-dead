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
			$Explosion1.play(&"default")
			Global.audio.play_sfx(&"explosion_2")
		2:
			$Explosion2.play(&"default")
			$Explosion3.play(&"default")
			$Explosion4.play(&"default")
			$Explosion5.play(&"default")
		3:			
			$Explosion6.play(&"default")
			$Explosion7.play(&"default")
			$Explosion8.play(&"default")
			$Explosion9.play(&"default")
			$Explosion10.play(&"default")
			$Explosion11.play(&"default")
			$Explosion12.play(&"default")
			$Explosion13.play(&"default")
			$Explosion14.play(&"default")
