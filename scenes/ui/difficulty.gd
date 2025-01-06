extends BaseUI

func _init():
	super._init(&"difficulty")

func _on_button_easy_pressed() -> void:
	Global.game_difficulty = Global.GameDifficulty.EASY
	Global.game.start_select()

func _on_button_normal_pressed() -> void:
	Global.game_difficulty = Global.GameDifficulty.NORMAL
	Global.game.start_select()

func _on_button_hard_pressed() -> void:
	Global.game_difficulty = Global.GameDifficulty.HARD
	Global.game.start_select()
