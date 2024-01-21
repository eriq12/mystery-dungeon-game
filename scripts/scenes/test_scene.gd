extends Node3D

@export var dungeon_node : Dungeon
@export var training_dummy : PackedScene
@export var dummy_spawn_location : Vector2i
@export var player_scene : PackedScene

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var player_char : Character = (player_scene.instantiate() as Character)
	if player_char:
		dungeon_node.enter_character(player_char)
	if training_dummy:
		dungeon_node.spawn_entity(training_dummy, 0, dummy_spawn_location)
