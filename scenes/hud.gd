extends Node2D

@onready var boost: Node2D = $Boost
@onready var progress: Node2D = $Progress

func _ready() -> void:
	get_viewport().connect(&"size_changed", _on_screen_resized)
	_update_position()

func _on_screen_resized():
	_update_position()
		
func _update_position() -> void:
	# Hud scale is 2.0
	var available_space = Vector2(get_viewport().size) / 2.0
	var offset = Vector2(available_space.x - 24.0 - 192, 24)
	boost.position = offset

	offset = Vector2(available_space.x - 24.0 - 16, available_space.y - 24 - 64 - 16)
	progress.position = offset
