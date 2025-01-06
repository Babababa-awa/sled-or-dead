extends KillableUnit
class_name YellowKillableUnit

var is_yellow: bool = false
		
func _update_yellow() -> void:
	pass
	
func _update_default() -> void:
	pass

func start() -> void:
	super.start()
	
	if Global.game_difficulty == Global.GameDifficulty.EASY:
		is_yellow = true
		_update_yellow()
	else:
		is_yellow = false
		_update_default()
