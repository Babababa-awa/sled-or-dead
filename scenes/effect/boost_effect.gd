extends Line2D

@export var size: int = 10

func _ready() -> void:
	set_as_top_level(true)

func play() -> void:
	clear_points()
	visible = true
	
func stop() -> void:
	visible = false

func _physics_process(_delta: float) -> void:
	var point = get_parent().global_position
	if points.size() > 0 and point == points[points.size() - 1]:
		return
		
	add_point(point)
	if points.size() > size:
		remove_point(0)
