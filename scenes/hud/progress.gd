extends Node2D

const COOLDOWN_DELTA: float = 1
var cooldown: CooldownTimer

func _init() -> void:
	cooldown = CooldownTimer.new(COOLDOWN_DELTA, true)
	
func _ready() -> void:
	_update_progress()
	
func _process(delta: float) -> void:
	if Global.vehicle == null or Global.game_mode != Global.GameMode.NORMAL:
		return
		
	if not Global.game.is_enabled:
		return
		
	cooldown.process(delta)
		
	if cooldown.start():
		_update_progress()
		
func _update_progress() -> void:
	var distance 
	
	if Global.vehicle == null:
		distance = 0
	elif Global.game.is_win:
		distance = Global.MAX_MAP_HEIGHT
	else:
		distance = Global.vehicle.get_distance_travelled()
		distance = min(Global.MAX_MAP_HEIGHT, distance)
		
	# 128 since points are -64 to 64
	var y = 64 - round(float(distance) / Global.MAX_MAP_HEIGHT * 128)
	
	$TrackBall.position.y = y

	if Global.level is SledLevel:
		$TrackBall.play(str(Global.level.map.current_difficulty))
	else:
		$TrackBall.play("1")
	
	$Marker2D/Line2DRemaining.points[0].y = y
	$Marker2D/Line2DCurrent.points[1].y = y
	
