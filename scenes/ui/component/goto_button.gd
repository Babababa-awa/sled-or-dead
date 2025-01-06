extends Button
class_name GotoButton

@export var goto_ui_id: StringName

func _on_pressed() -> void:
	var parent = get_parent()
		
	while parent != null:
		if parent is BaseUI:
			parent.goto(goto_ui_id)
			break
		
		parent = parent.get_parent()
