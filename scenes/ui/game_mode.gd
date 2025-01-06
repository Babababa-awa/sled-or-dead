extends BaseUI

func _init():
	super._init(&"game_mode")

func _on_goto_button_finish_line_pressed() -> void:
	Global.game_mode = Global.GameMode.NORMAL

func _on_goto_button_infinite_pressed() -> void:
	Global.game_mode = Global.GameMode.INFINITE
