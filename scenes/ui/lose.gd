extends BaseUI

func _init():
	super._init(&"lose")
	
func _ready() -> void:
	_update_button_visibility()

func show_ui():
	super.show_ui()
	Global.audio.play_sfx(&"ui/failure")
	
	if Global.vehicle != null:
		%Label2Distance.text = Global.format_distance(Global.vehicle.get_distance_travelled())
		%Label2Time.text = Global.format_time(Global.vehicle.get_time_travelled())
	else:
		%Label2Distance.text = Global.format_distance(0)
		%Label2Time.text = Global.format_time(0)
	
	_update_button_visibility()
	
func _update_button_visibility() -> void:
	if Global.game_difficulty == Global.GameDifficulty.EASY:
		%ButtonTryAgainEasy.visible = false
		%ButtonTryAgainNormal.visible = false
	elif Global.game_difficulty == Global.GameDifficulty.NORMAL:
		%ButtonTryAgainEasy.visible = true
		%ButtonTryAgainNormal.visible = false
	else:
		%ButtonTryAgainEasy.visible = false
		%ButtonTryAgainNormal.visible = true

func _on_button_try_again_pressed() -> void:
	Global.game.restart()

func _on_button_try_again_easy_pressed() -> void:
	Global.game_difficulty = Global.GameDifficulty.EASY
	Global.game.restart()

func _on_button_try_again_normal_pressed() -> void:
	Global.game_difficulty = Global.GameDifficulty.NORMAL
	Global.game.restart()
