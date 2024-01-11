extends Node3D

class_name EntityList

var associated_floor_level : Dictionary

signal character_cast_move(character : Character, move : Character_Move)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for child : Node3D in get_children():
		var character : Character = child as Character
		if character:
			character.stamina = 0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta : float) -> void:
	for child : Node3D in get_children():
		var character : Character = child as Character
		if not character:
			return
		character.stamina = min(character.stamina + delta, character.stamina_maximum)
		if character.stamina == character.stamina_maximum and character.has_queued_move:
			var character_move : Character_Move = character.dequeue_move()
			character_cast_move.emit(character, character_move)

func add_entity(entity : Character, level_id : int = -1) -> void:
	add_child(entity)
	entity.stamina = 0
	associated_floor_level[entity] = level_id
