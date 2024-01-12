extends Node3D

class_name Character

#region appearance data

var character_id : int

var character_model : Mesh

var character_render : Node3D

#endregion

#region action/move data

var orientation : TileMapLevel.Direction

var has_queued_move : bool : get = _has_queued_move

const walk_preset : CharacterMove = preload("res://moves/preset_moves/movement/walk_direction_move.tres")

const face_preset : CharacterMove = preload("res://moves/preset_moves/movement/face_direction_move.tres")

var brain : CharacterBrain : get = get_brain

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

func _ready() -> void:
	character_render = get_child(0)

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

func get_brain() -> CharacterBrain:
	if brain != null:
		return brain
	for node in get_children():
		if node.is_class("CharacterBrain"):
			brain = node
	return brain

func dequeue_move() -> CharacterMove:
	return brain.dequeue_move() if brain else null

func _has_queued_move() -> bool:
	return brain and brain.has_queued_move

func dequeue_direction() -> TileMapLevel.Direction:
	return brain.dequeue_direction() if brain else TileMapLevel.Direction.NONE

#endregion
