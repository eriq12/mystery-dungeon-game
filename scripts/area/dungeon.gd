extends Node3D

class_name Dungeon

#region node and function aliases

@onready var move_processor : Callable = Callable(self, "_on_entity_list_character_cast_move")

@export var dungeon_entities : EntityList

@export var levels : Array[TileMapLevel] 

@export var default_entrance_level_index : int = 0

@export var default_entrance_entry_point_index : int = 0
#endregion

# Called when the node enters the scene tree for the first time.
func _ready()  -> void:
	if not dungeon_entities and has_node("EntityList"):
		dungeon_entities = get_node("EntityList")
		if not dungeon_entities.character_cast_move.is_connected(move_processor):
			dungeon_entities.character_cast_move.connect(move_processor)

#region character location processing

func enter_character(character:Character, entering_level_index : int = default_entrance_entry_point_index, entering_endpoint : int = default_entrance_level_index) -> bool:
	var entrance_level : TileMapLevel = levels[entering_level_index]
	if entering_endpoint >= len(entrance_level.level_endpoints):
		entering_endpoint = 0
	if character:
		dungeon_entities.add_entity(character)
		if character.is_player_character and not entrance_level.is_reveal_signal_connected(character.on_location_change):
			# connect change to location
			entrance_level.connect_reveal_signal(character.on_location_change)
		if not _set_character_location(character, entrance_level.level_endpoints[entering_endpoint], entering_level_index):
			return false
		return true
	return false

func spawn_entity(entity : PackedScene, level_id : int, location: Vector2i) -> void:
	var character : Character = entity.instantiate()
	if not character:
		return
	dungeon_entities.add_entity(character)
	if not _set_character_location(character, location, level_id):
		character.free()

func _move_character(character : Character, location_offset : Vector2i, level : int = -1) -> bool:
	var location : Vector2i = character.location + location_offset
	return _set_character_location(character, location, level)

func _set_character_location(character : Character, location : Vector2i, level : int = -1) -> bool:
	var old_level : int = dungeon_entities.associated_floor_level[character] if dungeon_entities.associated_floor_level.has(character) else -1
	if level < 0:
		level = old_level
	if level >= len(levels) or level < 0:
		return false
	var v3location : Vector3i = Vector3i(location.x, 0, location.y)
	if level != old_level or levels[level].update_character_location(character, v3location):
		character.set_grid_location(location)
		character.set_level_location(level)
		if level != old_level:
			if old_level >= 0:
				levels[old_level].remove_character(character)
			levels[level].enter_character(character, v3location)
			dungeon_entities.associated_floor_level[character] = level
		character.transform.origin = dungeon_entities.to_local(levels[level].get_global_tile_position(v3location))
		return true
	return false


func _orient_character(character : Character, direction : TileMapLevel.Direction) -> void:
	match direction:
		TileMapLevel.Direction.NORTH:
			character.visual_look_at(Vector3.FORWARD)
			character.orientation = TileMapLevel.Direction.NORTH
		TileMapLevel.Direction.SOUTH:
			character.visual_look_at(Vector3.BACK)
			character.orientation = TileMapLevel.Direction.SOUTH
		TileMapLevel.Direction.EAST:
			character.visual_look_at(Vector3.RIGHT)
			character.orientation = TileMapLevel.Direction.EAST
		TileMapLevel.Direction.WEST:
			character.visual_look_at(Vector3.LEFT)
			character.orientation = TileMapLevel.Direction.WEST

#endregion

#region move processing

func process_move_effect(caster : Character, effect : MoveEffect) -> void:
	var direction : TileMapLevel.Direction = caster.dequeue_direction()
	if direction == TileMapLevel.Direction.NONE:
		direction = caster.orientation
	match effect.type_effect:
		MoveEffect.Type_Effect.MOVEMENT:
			var movement_effect : MoveEffectMovement = effect as MoveEffectMovement
			if not movement_effect:
				return
			if movement_effect.tiles_moved > 0:
				_move_character(caster, TileMapLevel.preset_direction[direction])
			elif direction != TileMapLevel.Direction.NONE:
				_orient_character(caster, direction)
		MoveEffect.Type_Effect.HEALTH_EFFECT:
			
			pass

func _on_entity_list_character_cast_move(character:Character, move:CharacterMove) -> void:
	if character.stamina >= move.stamina_cost:
		character.stamina -= move.stamina_cost
		move.effects.all(func(effect : MoveEffect) -> void : process_move_effect(character, effect))

#endregion
