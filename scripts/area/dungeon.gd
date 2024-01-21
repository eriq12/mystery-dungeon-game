extends Node3D

class_name Dungeon

#region node and function aliases

@onready var move_processor : Callable = Callable(self, "_on_entity_list_character_cast_move")

@onready var death_processor : Callable = Callable(self, "_on_character_death")

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
		if not dungeon_entities.character_death.is_connected(death_processor):
			dungeon_entities.character_death.connect(death_processor)

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
	if level != old_level or levels[level].update_character_location(character, location):
		character.set_grid_location(location)
		character.set_level_location(level)
		if level != old_level:
			if old_level >= 0:
				levels[old_level].remove_character(character)
			levels[level].enter_character(character, location)
			dungeon_entities.associated_floor_level[character] = level
		character.transform.origin = dungeon_entities.to_local(levels[level].get_global_tile_position(location))
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

func _apply_effect_linearly(character : Character, effect : MoveEffect, direction : TileMapLevel.Direction, reach : int) -> void:
	var direction_vector : Vector2i = TileMapLevel.preset_direction[direction]
	var level : int = dungeon_entities.associated_floor_level[character]
	for i in range(1, reach+1):
		var target_character : Character = levels[level].get_character_by_location(character.location + (direction_vector * i))
		if target_character:
			_apply_effect_on(character, target_character, effect)

func _apply_effect_on(caster : Character, target : Character, effect : MoveEffect) -> void:
	match effect.type_effect:
		MoveEffect.Type_Effect.HEALTH_EFFECT:
			var damage_effect : MoveEffectDamage = effect as MoveEffectDamage
			if damage_effect:
				print("%s attacked %s!" % [caster, target])
				var damage_received : int = target.damage(damage_effect.damage_value + caster.stats.attack)
				print("%s received %d damage!" % [target, damage_received])
		
#endregion

#region move processing

func process_move_action(caster : Character, action : MoveAction, desired_direction : TileMapLevel.Direction) -> void:
	var direction : TileMapLevel.Direction = caster.dequeue_direction()
	if direction == TileMapLevel.Direction.NONE:
		direction = caster.orientation
	match action.targeting:
		MoveAction.Targeting_Type.SELF:
			match action.move_effect.type_effect:
				MoveEffect.Type_Effect.ORIENT:
					_orient_character(caster, desired_direction)
		MoveAction.Targeting_Type.FRONT:
			match action.move_effect.type_effect:
				MoveEffect.Type_Effect.MOVEMENT:
					_move_character(caster, TileMapLevel.preset_direction[caster.orientation])
				_:
					_apply_effect_linearly(caster, action.move_effect, caster.orientation, 1)

func _on_entity_list_character_cast_move(character:Character, move:CharacterMove) -> void:
	if character.stamina >= move.stamina_cost:
		character.stamina -= move.stamina_cost
		var new_direction : TileMapLevel.Direction = character.dequeue_direction()
		move.actions.all(func(action : MoveAction) -> void : process_move_action(character, action, new_direction)) 
#endregion

func _on_character_death(character : Character) -> void:
	print("%s has died!")
	var level : int = dungeon_entities.remove_entity(character)
	if level >= 0:
		levels[level].remove_character(character)
		character.free()
