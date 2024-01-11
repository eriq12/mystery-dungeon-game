extends GridMap

class_name FogOfWar


func change_reveal_tiles_to(reveal_positions : Array[Vector3i]) -> void:
	for reveal_tile_position : Vector3i in reveal_positions:
		set_cell_item(reveal_tile_position, INVALID_CELL_ITEM)

