extends Node

var basic_move : CharacterMove = load("res://resources/moves/preset_moves/movement/walk_direction_move.tres")

var basic_face : CharacterMove = load("res://resources/moves/preset_moves/movement/face_direction_move.tres")

@export var move_database : Array[CharacterMove]