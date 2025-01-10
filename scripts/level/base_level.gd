extends Node2D
class_name BaseLevel

signal started

var alias: StringName

func _init(alias_: StringName) -> void:
	alias = alias_

func set_mode(mode: StringName) -> void:
	pass
	
func _ready() -> void:
	pass
	
func _process(_delta: float) -> void:
	pass

func start() -> void:
	started.emit()

func restart() -> void:
	started.emit()
