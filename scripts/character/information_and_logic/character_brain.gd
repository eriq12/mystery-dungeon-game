extends Node

class_name CharacterBrain

var has_queued_move : bool : get = _has_queued_move

var _queued_orientation : TileMapLevel.Direction = TileMapLevel.Direction.NONE

var _queued_move : CharacterMove

var orientation : TileMapLevel.Direction

#region move processing

func _has_queued_move() -> bool:
	return _queued_move != null

func set_queued_move(new_move : CharacterMove) -> void:
	_queued_move = new_move

func dequeue_move() -> CharacterMove:
	var result : CharacterMove = _queued_move
	_queued_move = null
	return result

#endregion

#region direction processing

func dequeue_direction() -> TileMapLevel.Direction:
	var return_direction : TileMapLevel.Direction = _queued_orientation
	_queued_orientation = TileMapLevel.Direction.NONE
	return return_direction

func set_queued_direction(new_direction : TileMapLevel.Direction = TileMapLevel.Direction.NONE) -> void:
	_queued_orientation = new_direction

#endregion