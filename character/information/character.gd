extends Node3D

class_name Character

#region appearance data

var character_id : int

var character_model : Mesh

var character_render : Node3D

#endregion

#region action/move data

var orientation : TileMapLevel.Direction

var queued_orientation : TileMapLevel.Direction = TileMapLevel.Direction.NONE

var _queued_move : Character_Move = null

var has_queued_move : bool : get = _has_queued_move

var walk_preset : Character_Move = load("res://moves/preset_moves/movement/walk_direction_move.tres")

var face_preset : Character_Move = load("res://moves/preset_moves/movement/face_direction_move.tres")

#endregion

#region stamina

@export var stamina_maximum : float = 1

var stamina : float = 0

#endregion

#region location data

signal on_location_change(new_location : Vector3i)
var location : Vector3i

#endregion

#region misc stats

var view_range : int = 5

#endregion

func set_grid_location(new_location : Vector3i) -> void:
	location = new_location
	on_location_change.emit(new_location, view_range)

func visual_look_at(relative_direction : Vector3) -> void:
	if not character_render:
		return
	character_render.look_at(transform.origin + relative_direction)

func set_view_distance(new_distance : int) -> void:
	view_range = new_distance

#region move queue handling

func dequeue_move() -> Character_Move:
	var return_move : Character_Move = _queued_move
	_queued_move = null
	return return_move

func _has_queued_move() -> bool:
	return not _queued_move == null

func set_queued_move(new_move : Character_Move) -> void:
	_queued_move = new_move

func dequeue_direction() -> TileMapLevel.Direction:
	var return_direction : TileMapLevel.Direction = queued_orientation
	queued_orientation = TileMapLevel.Direction.NONE
	return return_direction

func set_queued_direction(new_direction : TileMapLevel.Direction = TileMapLevel.Direction.NONE) -> void:
	queued_orientation = new_direction

#endregion
