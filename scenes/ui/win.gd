extends BaseUI

func _init():
	super._init(&"win")
	
func _ready() -> void:
	_update_button_visibility()

func show_ui():
	super.show_ui()
	
	Global.audio.play_sfx(&"ui/winner")
	_update_button_visibility()

		
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
