extends GridMap

class_name FogOfWar


func change_reveal_tiles_to(reveal_positions : Array[Vector2i]) -> void:
	for reveal_tile_position : Vector2i in reveal_positions:
		reveal_tile(reveal_tile_position)

func reveal_tile(location : Vector2i) -> void:
	set_cell_item(Vector3i(location.x, 0, location.y), INVALID_CELL_ITEM)