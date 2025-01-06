extends BaseUI

func _init():
	super._init(&"pause")
	
func show_ui():
	super.show_ui()
	
	if Global.vehicle != null:
		%Label2Distance.text = str(-round(Global.vehicle.position.y / Global.TILE_SIZE) - 8) + "m"
	else:
		%Label2Distance.text = "0m"


func _on_button_continue_pressed() -> void:
	hide_ui()
	Global.game.toggle_pause()
