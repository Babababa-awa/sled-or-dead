extends Node2D

func _ready() -> void:
	_update()

func _process(_delta: float) -> void:
	_update()
	
func _update() -> void:
	if not Global.vehicle:
		$TileMapLayerState.set_cell(Vector2i(0, 0))
		return
	
	var boost = Global.vehicle.boost
	
	if boost == 0.0:
		$TileMapLayerState.set_cell(Vector2i(0, 0))
		return
	elif boost == 100.0:
		$TileMapLayerState.set_cell(Vector2i(0, 0), $TileMapLayerState.tile_set.get_source_id(0), Vector2i(0, 1))
		return

	var index = int(round(5.0 * boost / 100))
	
	if index == 5:
		index = 4
	elif index == 0:
		index = 1
		
	index = 5 - index
	
	$TileMapLayerState.set_cell(Vector2i(0, 0), $TileMapLayerState.tile_set.get_source_id(0), Vector2i(0, index + 1))
