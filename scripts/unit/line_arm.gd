extends Line2D
class_name LineArm

var min_length: float

func _init(min_length_: float) -> void:
	min_length = min_length_
	
func calculate_center_with_min_distance(pos1: Vector2, pos2: Vector2) -> Vector2:
	var midpoint = (pos1 + pos2) / 2.0
	
	var total_length = pos1.distance_to(pos2)
	
	if total_length < min_length:
		midpoint -= Vector2(1, 1) * (min_length - total_length) / 2
	
	return midpoint

	
	
