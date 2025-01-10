extends BaseUI

func _init():
	super._init(&"win")
	
func _ready() -> void:
	_update_button_visibility()

func show_ui():
	super.show_ui()
	
	Global.audio.play_sfx(&"ui/winner")
	_update_button_visibility()
	
	if Global.vehicle != null:
		%Label2Distance.text = Global.format_distance(Global.vehicle.get_distance_travelled())
		%Label2Time.text = Global.format_time(Global.vehicle.get_time_travelled())
	else:
		%Label2Distance.text = Global.format_distance(0)
		%Label2Time.text = Global.format_time(0)

		
func _update_button_visibility() -> void:
	if Global.game_difficulty == Global.GameDifficulty.EASY:
		%ButtonPlayAgainNormal.visible = true
		%ButtonPlayAgainHard.visible = false
	elif Global.game_difficulty == Global.GameDifficulty.NORMAL:
		%ButtonPlayAgainNormal.visible = false
		%ButtonPlayAgainHard.visible = true
	else:
		%ButtonPlayAgainNormal.visible = false
		%ButtonPlayAgainHard.visible = false

func _on_button_play_again_pressed() -> void:
	Global.game.restart()

func _on_button_play_again_normal_pressed() -> void:
	Global.game_difficulty = Global.GameDifficulty.NORMAL
	Global.game.restart()

func _on_button_play_again_hard_pressed() -> void:
	Global.game_difficulty = Global.GameDifficulty.HARD
	Global.game.restart()
