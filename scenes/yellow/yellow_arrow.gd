extends YellowBaseNode2D

@onready var sprite: Sprite2D = $Sprite2D

func _update_default() -> void:
	sprite.visible = false
	
func _update_yellow() -> void:
	sprite.visible = true
