extends Node3D

class_name TileMapLevel

#region constants and enums

enum Direction {NONE=-1, NORTH, EAST, SOUTH, WEST};

enum Tile_Status {EMPTY=-1, ITEM, OCCUPIED, IMPASSIBLE}

const preset_direction : Array[Vector3i] = [Vector3i.FORWARD, Vector3i.RIGHT, Vector3i.BACK, Vector3i.LEFT]

@export var max_bound_from_origin : int = 32

#endregion

@export var level_wall : GridMap

@export var level_floor : GridMap

@export var dungeon_fog_of_war : FogOfWar

@export var dungeon_endpoints : Array[Vector3i]

@onready var reveal_change_processor : Callable = Callable(self, "_update_reveal_tiles")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if not level_floor and has_node("LevelFloor"):
		level_floor = get_node("LevelFloor")
	if not level_wall and has_node("LevelWall"):
		level_wall = get_node("LevelWall")
	if not dungeon_fog_of_war and has_node("FogOfWar"):
		dungeon_fog_of_war = get_node("FogOfWar") as FogOfWar
		for x : int in range(-max_bound_from_origin, max_bound_from_origin):
			for z : int in range(-max_bound_from_origin, max_bound_from_origin):
				dungeon_fog_of_war.set_cell_item(Vector3i(x, 0, z), 0)
	if len(dungeon_endpoints) == 0:
		dungeon_endpoints.append(Vector3i(0,0,0))


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta : float) -> void:
	pass

func get_view_tiles(location : Vector3i, callback : Callable, view_distance : int, accuracy_band : int = 1) -> void:
	var angles : Array[float] = []
	for section in range(4):
		angles.append(PI/2 * section)
	for visibility_range : int in range(view_distance + 1 - accuracy_band, view_distance + 1):
		for section : int in range(4):
			for step : int in range(1, visibility_range):
				angles.append(atan(step as float / (visibility_range - step)) + PI/2 * section)
	var quick_access : Dictionary = {}
	for angle : float in angles:
		var forward_ratio : float = sin(angle)
		var horizontal_ratio : float = cos(angle)
		for distance : int in range(view_distance):
			var tile : Vector3i = location + Vector3i.FORWARD * (round(forward_ratio * distance) as int) + Vector3i.RIGHT * (round(horizontal_ratio * distance) as int)
			if quick_access.has(tile):
				if quick_access[tile]:
					continue
				else:
					break
			if _is_tile_obstructed(location, tile):
				quick_access[tile] = false
				break
			callback.call(tile)
			if _get_tile_status(tile) == Tile_Status.IMPASSIBLE:
				quick_access[tile] = false
				break
			quick_access[tile] = true

func get_manhattan_approx(point1 : Vector3i, point2 : Vector3i) -> int:
	return abs(point1.x - point2.x) + abs(point1.y - point2.y) + abs(point1.z - point2.z)

func get_global_tile_position(location : Vector3i) -> Vector3:
	return level_floor.to_global(level_floor.map_to_local(location) + Vector3.DOWN)

func is_reveal_signal_connected(reveal_signal : Signal) -> bool:
	return reveal_signal.is_connected(reveal_change_processor)

func connect_reveal_signal(reveal_signal : Signal) -> void:
	reveal_signal.connect(reveal_change_processor)

func _get_tile_status(location : Vector3i) -> Tile_Status:
	match level_wall.get_cell_item(location):
		GridMap.INVALID_CELL_ITEM:
			return Tile_Status.EMPTY
	return Tile_Status.IMPASSIBLE

func _is_tile_obstructed(view_point : Vector3i, tile_viewed : Vector3i) -> bool:
	var delta_x : int = view_point.x - tile_viewed.x
	var delta_z : int = view_point.z - tile_viewed.z
	if delta_x == 0 or delta_z == 0:
		return false
	delta_x /= abs(delta_x)
	delta_z /= abs(delta_z)
	var tile_horizontal_closer : Vector3i = tile_viewed + Vector3i.RIGHT * delta_x
	var tile_vertical_closer : Vector3i = tile_viewed + Vector3i.BACK * delta_z
	return _get_tile_status(tile_horizontal_closer) == Tile_Status.IMPASSIBLE and _get_tile_status(tile_vertical_closer) == Tile_Status.IMPASSIBLE

func _update_reveal_tiles(location : Vector3i, view_distance : int) -> void:
	var view_tiles : Array[Vector3i] = []
	get_view_tiles(location,
		func (tile : Vector3i) -> void:
			view_tiles.append(tile)
	, view_distance, 2)
	dungeon_fog_of_war.change_reveal_tiles_to(view_tiles)
