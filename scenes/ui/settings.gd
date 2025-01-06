extends BaseUI

func _init():
	super._init(&"settings")

@onready var music_bus = AudioServer.get_bus_index("Music")
@onready var sfx_bus = AudioServer.get_bus_index("SFX")

func show_ui() -> void:
	super.show_ui()
	%HSliderMusic.value = db_to_linear(AudioServer.get_bus_volume_db(music_bus))
	%HSliderSFX.value = db_to_linear(AudioServer.get_bus_volume_db(sfx_bus))
	
func _on_h_slider_music_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(music_bus, linear_to_db(value))
	AudioServer.set_bus_mute(music_bus, value < 0.05)

func _on_h_slider_sfx_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(sfx_bus, linear_to_db(value))
	AudioServer.set_bus_mute(sfx_bus, value < 0.05)
	
