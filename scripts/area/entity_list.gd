extends Node3D

class_name EntityList

var associated_floor_level : Dictionary

signal character_cast_move(character : Character, move : CharacterMove)

signal character_death(character : Character)

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
		if not character.alive:
			character_death.emit(character)
		elif character.stamina == character.stamina_maximum and character.has_queued_move:
			var character_move : CharacterMove = character.dequeue_move()
			character_cast_move.emit(character, character_move)

func add_entity(entity : Character, level_id : int = -1) -> void:
	add_child(entity)
	entity.stamina = 0
	associated_floor_level[entity] = level_id

func remove_entity(entity : Character) -> int:
	var level : int = associated_floor_level.get(entity, -1)
	associated_floor_level.erase(entity)
	return level

func get_entity_level(character : Character) -> int:
	if not associated_floor_level.has(character):
		return -1
	return associated_floor_level[character]

func update_character_floor_level(character : Character, level_id : int) -> void:
	associated_floor_level[character] = level_id