class_name MapObstacle

var position: Vector2
var _obstacle: Dictionary

var scene: String:
	get:
		return _obstacle.scene
	set(value):
		_obstacle.scene = value

func _init(position_: Vector2, obstacle_: Dictionary) -> void:
	position = position_
	_obstacle = obstacle_
