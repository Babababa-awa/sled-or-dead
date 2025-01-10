extends BaseUI

func _init():
	super._init(&"pause")
	
func show_ui():
	super.show_ui()
	
	if Global.vehicle != null:
		%Label2Distance.text = Global.format_distance(Global.vehicle.get_distance_travelled())
		%Label2Time.text = Global.format_time(Global.vehicle.get_time_travelled())
	else:
		%Label2Distance.text = Global.format_distance(0)
		%Label2Time.text = Global.format_time(0)


func _on_button_continue_pressed() -> void:
	hide_ui()
	Global.game.toggle_pause()
