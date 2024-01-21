extends RefCounted

class_name LocalAreaData

var tiles : Array[Vector2i]
var entities : Dictionary
var items : Dictionary

func add_tile(tile_location : Vector2i, entity : Character = null) -> void:
    tiles.append(tile_location)
    if not entity == null:
        entities[tile_location] = entity

func get_entities() -> Array[Character]:
    return entities.values()

func get_entity(title_location : Vector2i) -> Character:
    if not entities.has(title_location):
        return null
    return entities[title_location]