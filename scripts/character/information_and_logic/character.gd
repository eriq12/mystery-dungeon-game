extends Node3D

class_name Character

#region appearance data

var character_id : int

var character_render : Node3D

#endregion

#region action/move data

var orientation : TileMapLevel.Direction : get = _get_orientation, set = _set_orientation

var has_queued_move : bool : get = _has_queued_move

var brain : CharacterBrain : get = get_brain

var _brain_cache : CharacterBrain

var is_player_character : bool : get = _is_player_character

#endregion

#region character stats

@export var base_stats : CharacterBaseStats

@export var stats : CharacterStats

var alive : bool : get = _is_alive

var stamina_maximum : float : get = get_maximum_stamina

var stamina : float = 0

signal on_death(character : Character)

#endregion

#region location data

signal on_location_change(new_location : Vector2i, view_range : int)

var location : Vector2i

var level_id : int

#endregion

#region misc stats

var view_range : int = 5

#endregion

func _ready() -> void:
	character_render = get_child(0)
	_update_brain()
	if not base_stats:
		base_stats = load("res://resources/character_base_stat_data/adventurer.tres") as CharacterBaseStats
	if not stats:
		stats = CharacterStats.new(base_stats)

func _update_brain() -> void:
	for node in get_children():
		_brain_cache = node as CharacterBrain
		if _brain_cache:
			break

func _is_player_character() -> bool:
	return brain as PlayerBrain != null

#region health handling

func damage(damage_value : int) -> int:
	return stats.deplete_health_by(damage_value)

#endregion

#region location and orientation handling

func set_grid_location(new_location : Vector2i) -> void:
	location = new_location
	on_location_change.emit(new_location, view_range)

func set_level_location(new_level_id : int) -> void:
	level_id = new_level_id

func visual_look_at(relative_direction : Vector3) -> void:
	if not character_render:
		return
	character_render.look_at(transform.origin + relative_direction)

func set_view_distance(new_distance : int) -> void:
	view_range = new_distance

func _get_orientation() -> TileMapLevel.Direction:
	return orientation

func _set_orientation(new_direction : TileMapLevel.Direction) -> void:
	if _brain_cache:
		_brain_cache.orientation = new_direction
	orientation = new_direction

#endregion

#region move queue handling

func get_brain() -> CharacterBrain:
	if not _brain_cache :
		_update_brain()
	return _brain_cache

func dequeue_move() -> CharacterMove:
	return _brain_cache.dequeue_move() if brain else null

func _has_queued_move() -> bool:
	return _brain_cache and _brain_cache.has_queued_move

func dequeue_direction() -> TileMapLevel.Direction:
	return _brain_cache.dequeue_direction() if _brain_cache else TileMapLevel.Direction.NONE

#endregion

#region stats getters

func get_maximum_stamina() -> float:
	return stats.stamina

func _is_alive() -> bool:
	return stats and stats.is_alive

func _to_string() -> String:
	return stats._to_string()
#endregion
