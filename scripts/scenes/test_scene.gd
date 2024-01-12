extends Node3D

@export var dungeon_node : Dungeon
@export var player_scene : PackedScene

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var player_char : Character = (player_scene.instantiate() as Character)
	if player_char:
		dungeon_node.enter_character(player_char)
