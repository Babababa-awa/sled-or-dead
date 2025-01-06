extends BaseNode2D
class_name YellowBaseNode2D

var is_yellow: bool = false

func _ready() -> void:
	_reset_yellow()
	
func _update_yellow() -> void:
	pass
	
func _update_default() -> void:
	pass

func start() -> void:
	super.start()
	_reset_yellow()

func _reset_yellow() -> void:
	if Global.game_difficulty == Global.GameDifficulty.EASY:
		if not is_yellow:
			is_yellow = true
			_update_yellow()
	elif is_yellow:
		is_yellow = false
		_update_default()
