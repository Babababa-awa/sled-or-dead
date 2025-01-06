extends CharacterBody2D
class_name BaseUnit
 
var alias: StringName
var unit_type: Global.UnitType

var is_enabled: bool = true
var is_started: bool = false
var is_ready: bool = false
var is_hidden: bool = false

func _init(alias_: StringName, unit_type_: Global.UnitType) -> void:
	alias = alias_
	unit_type = unit_type_
	
func reset() -> void:
	velocity = Vector2(0, 0)
	scale = Vector2(1.0, 1.0)
	
	is_enabled = true
	is_started = false
	
	_show_unit()

func _ready() -> void:
	pass
	
func _process(_delta: float) -> void:
	# We check is_ready here so overriding wont allow calling 
	# it after alrady being ready
	if not is_ready:
		_handle_ready()

func _handle_ready() -> void:
	if is_ready:
		return
		
	if not Global.game.is_enabled:
		return
		
	if not is_started:
		return
		
	if position == Global.NODE_LOADER_DEAD_ZONE:
		return
		
	is_ready = true
	
func _can_process() -> bool:
	if not Global.game.is_enabled:
		return false
	
	if not is_started or not is_ready:
		return false
		
	return true
	

func start() -> void:
	is_started = true
	is_ready = false

func stop() -> void:
	is_started = false
	is_ready = false

func show_speech_bubble(
	text: String, 
	delay: float = 2.0, 
	vertical_offset: float = -32,
) -> void:
	pass
	
func _hide_unit() -> void:
	is_hidden = true
	
func _show_unit() -> void:
	is_hidden = false
