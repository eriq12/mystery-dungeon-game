extends Resource

class_name CharacterBaseStats

enum Growth_Type {NORMAL, SLOW, LATE}
const _growth_multiplier_constants : Array[float] = [1.25, 2, 3.5]

@export var character_class_name : String = "Adventurer"

#region base stats

@export_group("Base Stats")

@export var health : int = 20

@export var attack : int = 5

@export var defense : int = 5

@export var stamina : int = 1

@export var growth : Growth_Type = Growth_Type.NORMAL

var growth_mutliplier : float : get = _get_growth_multiplier

#endregion

#region max_stats

@export_group("Max Level Stats")

@export_range(2,5) var max_heath_multiplier : float = 2

var max_health : int : get = _get_max_health

@export_range(2,5) var max_attack_multiplier : float = 2

var max_attack : int : get = _get_max_attack

@export_range(2,5) var max_defense_multiplier : float = 2

var max_defense : int : get = _get_max_defense

@export_range(2,5) var max_stamina_multiplier : float = 2

var max_stamina : int : get = _get_max_stamina

#endregion

func _init(new_character_class_name : String = "Adventurer", \
    new_health : int = 20,\
    new_attack : int = 5,\
    new_defense : int = 5,\
    new_stamina : int = 1\
    ) -> void:
    character_class_name = new_character_class_name
    health = new_health if new_health > 0 else 20
    attack = new_attack if new_attack > 0 else 5
    defense = new_defense if new_defense > 0 else 5
    stamina = new_stamina if new_stamina > 0 else 1

func get_full_character_name(character_name : String) -> String:
    if not character_class_name or len(character_class_name) == 0:
        return character_name
    elif not character_name or len(character_name) == 0:
        return character_class_name
    return "%s %s" % [character_class_name, character_name]

func _get_growth_multiplier() -> float:
    return _growth_multiplier_constants[growth]

#region get max stats

func _get_max_health() -> int:
    if max_heath_multiplier <= 1:
        max_heath_multiplier = 5
    return round(max_heath_multiplier * health) as int

func _get_max_attack() -> int:
    if max_attack_multiplier <= 1:
        max_attack_multiplier = 5
    return round(max_attack_multiplier * attack) as int

func _get_max_defense() -> int:
    if max_defense_multiplier <= 1:
        max_defense_multiplier = 5
    return round(max_defense_multiplier * defense) as int

func _get_max_stamina() -> int:
    if max_stamina_multiplier <= 1:
        max_stamina_multiplier = 5
    return round(max_stamina_multiplier * stamina) as int

#endregion