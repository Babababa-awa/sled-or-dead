extends YellowBaseNode2D

@onready var tile_map_layer: TileMapLayer = $TileMapLayerJump
	
func _update_default() -> void:
	if tile_map_layer != null:
		tile_map_layer.set_cell(Vector2i(0, 0), tile_map_layer.tile_set.get_source_id(0), Vector2i(0, 0))

func _update_yellow() -> void:
	if tile_map_layer != null:
		tile_map_layer.set_cell(Vector2i(0, 0), tile_map_layer.tile_set.get_source_id(0), Vector2i(1, 0))
