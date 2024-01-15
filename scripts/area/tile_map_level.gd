extends Node3D

class_name TileMapLevel

#region constants and enums

enum Direction {NONE=-1, NORTH, EAST, SOUTH, WEST};

enum Tile_Status {EMPTY=-1, ITEM, OCCUPIED, NONSOLID, IMPASSIBLE}

const preset_direction : Array[Vector2i] = [Vector2i.UP, Vector2i.RIGHT, Vector2i.DOWN, Vector2i.LEFT]

@export var max_bound_from_origin : int = 32

#endregion

#region gridmaps

@export var level_wall : GridMap

@export var level_floor : GridMap

@export var level_fog_of_war : FogOfWar

#endregion

#region data

@export var level_endpoints : Array[Vector2i]

var entities_by_location : Dictionary

var entity_locations : Dictionary

#endregion

@onready var reveal_change_processor : Callable = Callable(self, "_update_reveal_tiles")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if not level_floor and has_node("LevelFloor"):
		level_floor = get_node("LevelFloor")
	if not level_wall and has_node("LevelWall"):
		level_wall = get_node("LevelWall")
	if not level_fog_of_war and has_node("FogOfWar"):
		level_fog_of_war = get_node("FogOfWar") as FogOfWar
		for x : int in range(-max_bound_from_origin, max_bound_from_origin):
			for z : int in range(-max_bound_from_origin, max_bound_from_origin):
				level_fog_of_war.set_cell_item(Vector3i(x, 0, z), 0)
	if len(level_endpoints) == 0:
		level_endpoints.append(Vector2i(0,0))
	entities_by_location = {}
	entity_locations = {}

func get_manhattan_approx(point1 : Vector3i, point2 : Vector3i) -> int:
	return abs(point1.x - point2.x) + abs(point1.y - point2.y) + abs(point1.z - point2.z)

func get_global_tile_position(location : Vector2i) -> Vector3:
	return level_floor.to_global(level_floor.map_to_local(Vector3i(location.x, 0, location.y)) + Vector3.DOWN)

#region character locations

func enter_character(character : Character, location : Vector2i) -> bool:
	if entity_locations.has(character) or _get_tile_status(location) != Tile_Status.EMPTY:
		return false
	entities_by_location[location] = character
	entity_locations[character] = location
	return false

func remove_character(character : Character) -> bool:
	if not entity_locations.has(character):
		return false
	entities_by_location.erase(entity_locations[character])
	entity_locations.erase(character)
	return true

func update_character_location(character : Character, new_location : Vector2i) -> bool:
	if not entity_locations.has(character) or _get_tile_status(new_location) >= Tile_Status.OCCUPIED:
		return false
	if entity_locations[character] != new_location:
		entities_by_location.erase(entity_locations[character])
		entities_by_location[new_location] = character
		entity_locations[character] = new_location
	return true

#endregion

#region signal related

func is_reveal_signal_connected(reveal_signal : Signal) -> bool:
	return reveal_signal.is_connected(reveal_change_processor)

func connect_reveal_signal(reveal_signal : Signal) -> void:
	reveal_signal.connect(reveal_change_processor)

#endregion

#region helper methods

func _get_tile_status(v2location : Vector2i) -> Tile_Status:
	var location : Vector3i = v2location.x * Vector3i.RIGHT + v2location.y * Vector3i.BACK
	match level_wall.get_cell_item(location):
		GridMap.INVALID_CELL_ITEM:
			if entities_by_location.has(location):
				return Tile_Status.OCCUPIED
			return Tile_Status.EMPTY
	return Tile_Status.IMPASSIBLE

func _is_tile_obstructed(view_point : Vector2i, tile_viewed : Vector2i) -> bool:
	var delta_x : int = view_point.x - tile_viewed.x
	var delta_z : int = view_point.y - tile_viewed.y
	if delta_x == 0 or delta_z == 0:
		return false
	delta_x /= abs(delta_x)
	delta_z /= abs(delta_z)
	var tile_horizontal_closer : Vector2i = tile_viewed + Vector2i.RIGHT * delta_x
	var tile_vertical_closer : Vector2i = tile_viewed + Vector2i.DOWN * delta_z
	return _get_tile_status(tile_horizontal_closer) == Tile_Status.IMPASSIBLE and _get_tile_status(tile_vertical_closer) == Tile_Status.IMPASSIBLE

func _update_reveal_tiles(location : Vector2i, view_distance : int) -> void:
	var view_tiles : Array[Vector2i] = []
	_apply_on_viewable_tiles_from(location,
		func (tile : Vector2i) -> void:
			view_tiles.append(tile)
	, view_distance, 2)
	level_fog_of_war.change_reveal_tiles_to(view_tiles)

func _get_local_area_from(location : Vector2i, view_distance : int) -> LocalAreaData:
	return null

func _apply_on_viewable_tiles_from(location : Vector2i, callback : Callable, view_distance : int, accuracy_band : int = 2) -> void:
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
			var tile : Vector2i = location + Vector2i((round(forward_ratio * distance) as int), (round(horizontal_ratio * distance) as int))
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

#endregion