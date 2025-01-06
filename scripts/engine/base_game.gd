extends Node
class_name BaseGame

var current_level = null
var is_paused: bool = false
var _pause_volume: float = 0.0
var is_enabled: bool = true

var is_lose: bool = false
var _is_lose_handeld = false
var is_win: bool = false
var _is_win_handeld = false

func start() -> void:
	show_ui(&"loading")
	
	reset_level()
	reset_game()
	
	Global.nodes.reset()
	Global.help.reset()
	Global.audio.reset()
	
	start_load()
	_hide_mouse()
	hide_uis(Global.UIType.MENU)
	await change_level(Global.START_LEVEL)
	
func restart() -> void:
	if current_level == null:
		await start()
		return
		
	show_ui(&"loading")
		
	reset_game()
	
	Global.nodes.free_all()
	
	start_load()
	_hide_mouse()
	hide_uis(Global.UIType.MENU)
	hide_uis(Global.UIType.GAME)
	
	current_level.restart()
	
func _ready() -> void:
	Global.nodes = NodeLoader.new()
	Global.game = self
	Global.help = Help.new()
	Global.audio = Audio.new()
	Global.hud = $UI/Hud
	
	var music_bus = AudioServer.get_bus_index("Music")
	AudioServer.set_bus_volume_db(music_bus, linear_to_db(0.3))
	
	show_ui(&"loading")
	await change_level(Global.MENU_LEVEL)

func reset() -> void:
	show_ui(&"loading")
	
	reset_level()
	reset_game()
	
	Global.nodes.reset()
	Global.help.reset()
	Global.audio.reset()
	
	_show_mouse()
	await change_level(Global.MENU_LEVEL)
	
func reset_game() -> void:
	reset_state()
	reset_win_lose()

func reset_level() -> void:
	$Level.visible = false
	hide_uis(Global.UIType.GAME)
	
	if current_level != null:
		$Level.remove_child(current_level)
		current_level.queue_free()
		current_level = null
		Global.level = null

func reset_state() -> void:
	is_paused = false
	Engine.time_scale = 1
	is_enabled = true
	
	if Global.camera != null:
		Global.camera.position_smoothing_enabled = true

func reset_win_lose() -> void:
	is_lose = false
	_is_lose_handeld = false
	is_win = false
	_is_win_handeld = false

func add_level_child(node: Node2D) -> void:
	$Level.add_child.call_deferred(node)

func remove_level_child(node: Node2D) -> void:
	$Level.remove_child.call_deferred(node)
	
func change_level(level_alias: StringName) -> void:
	reset_level()
		
	var level_path = "res://scenes/level/" + level_alias + ".tscn"
	
	var level = await load(level_path).instantiate()

	$Level.add_child(level)
		
	current_level = level
	Global.level = level

	level.started.connect(_level_started)

	await level.start()
	
	$Level.visible = true
	
func _level_started() -> void:
	end_load()
	hide_ui(&"loading")
	
func start_load() -> void:
	if Global.camera != null:
		Global.camera.position_smoothing_enabled = false
	is_enabled = false
	#Engine.time_scale = 0
	
func end_load() -> void:
	if Global.camera != null:
		await get_tree().process_frame
		Global.camera.position_smoothing_enabled = true
	#Engine.time_scale = 1
	is_enabled = true

func _process(_delta):
	_handle_pause()
	
	if not is_enabled:
		return
	
	if is_lose and not _is_lose_handeld:
		_is_lose_handeld = true
		_show_mouse()
		Global.game.show_ui(&"lose")
		
	if is_win and not _is_win_handeld:
		_is_win_handeld = true
		_show_mouse()
		Global.game.show_ui(&"win")

func _physics_process(_delta: float) -> void:
	pass

func _handle_pause() -> void:
	if Input.is_action_just_pressed("game_pause") and current_level != null:
		toggle_pause()
		
func toggle_pause() -> void:
	if is_paused:
		is_paused = false
		is_enabled = true
		Engine.time_scale = 1
		if get_ui(&"settings").visible:
			var music_bus = AudioServer.get_bus_index("Music")
			_pause_volume = db_to_linear(AudioServer.get_bus_volume_db(music_bus))
		_increase_music_volume()
		_hide_mouse()
		hide_uis(Global.UIType.MENU)
	elif _can_pause():
		Engine.time_scale = 0
		is_enabled = false
		is_paused = true
		_decrease_music_volume()
		_show_mouse()
		show_ui(&"pause")

func _can_pause() -> bool:
	if not is_enabled:
		return false
		
	if has_visible_uis(Global.UIType.MENU):
		return false
	
	if current_level != null and current_level.alias == Global.MENU_LEVEL:
		return false
		
	return true

func get_ui(id: StringName) -> BaseUI:
	for child in $UI.get_children():
		if child is BaseUI and child.id == id:
			return child
		
	return null
	
func has_visible_uis(ui_type: Global.UIType) -> bool:
	for child in $UI.get_children():
		if child is BaseUI and child.ui_type == ui_type and child.visible:
			return true
		
	return false

func is_ui_visible(id: StringName) -> bool:
	var ui = get_ui(id)
	
	if ui != null and ui.visible == true:
		return true
		
	return false

func hide_uis(ui_type: Global.UIType) -> void:
	for child in $UI.get_children():
		if child is BaseUI and child.ui_type == ui_type:
			child.hide_ui()
			
	if ui_type == Global.UIType.GAME and Global.hud != null:
		Global.hud.visible = false

func hide_ui(id: StringName) -> void:
	var ui = get_ui(id)
	if ui != null:
		ui.hide_ui()
	elif id == &"hud" and Global.hud != null:
		Global.hud.visible = false
			
func show_ui(id: StringName) -> void:
	var ui = get_ui(id)
	if ui != null:
		ui.show_ui()
	elif id == &"hud" and Global.hud != null:
		Global.hud.visible = true
	
func prepare_ui_id(id: StringName, _from_id: StringName) -> StringName:
	if id != &"parent":
		return id
		
	if is_paused:
		return &"pause"
		
	return &"menu"
		
func prepare_ui(id: StringName, from_id: StringName) -> void:
	if id == &"menu":
		if current_level != null and current_level.alias != Global.MENU_LEVEL:
			show_ui(&"loading")
			reset()
	if id == &"settings" and from_id == &"pause":
		_increase_music_volume()
	elif id == &"pause"	and from_id == &"settings":
		_decrease_music_volume()
	
func _increase_music_volume() -> void:
	if _pause_volume == 0.0:
		return
		
	var music_bus = AudioServer.get_bus_index("Music")
	AudioServer.set_bus_volume_db(music_bus, linear_to_db(_pause_volume))
	AudioServer.set_bus_mute(music_bus, _pause_volume < 0.05)
	_pause_volume = 0.0
	
func _decrease_music_volume() -> void:
	var music_bus = AudioServer.get_bus_index("Music")
	_pause_volume = db_to_linear(AudioServer.get_bus_volume_db(music_bus))
	
	if _pause_volume != 0.0:
		AudioServer.set_bus_volume_db(music_bus, linear_to_db(_pause_volume / 3))
		AudioServer.set_bus_mute(music_bus, _pause_volume / 3 < 0.05)
		
	
func _hide_mouse() -> void:
	if Global.MOUSE_CAPTURE:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
		if Global.cursor:
			Global.cursor.visible = true

func _show_mouse() -> void:
	if Global.MOUSE_CAPTURE:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		
		if Global.cursor:
			Global.cursor.visible = false
