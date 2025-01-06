extends BaseUI

@onready var sprite_title: AnimatedSprite2D = $MarginContainer/AnimatedSprite2DTitle

func _init():
	super._init(&"menu")

func _ready() -> void:
	super._ready()
	_update_title_position()

func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		_update_title_position()
		
func _update_title_position() -> void:
	if sprite_title:
		var title_size = Vector2(160, 100) * sprite_title.scale
		var available_space = Vector2(get_viewport().size) / 2.0
		var offset = Vector2(available_space.x, available_space.y - (title_size.y / 2.0))
		
		sprite_title.position = offset

func _on_button_exit_pressed() -> void:
	get_tree().quit()
