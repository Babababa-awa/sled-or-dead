extends Node2D
class_name BaseNode2D

var is_started: bool = false

func reset() -> void:
	pass

func start() -> void:
	is_started = true
	
func stop() -> void:
	is_started = false

func set_mode(mode: StringName) -> void:
	pass
