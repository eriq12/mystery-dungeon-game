extends Resource

class_name CharacterStats

@export var base_stats : CharacterBaseStats

@export var level : int = 0

@export var name : String

var max_health : int : get = get_max_health

var _max_health_cache : int = 1

var health : int : get = get_health

var _health_cache : int

var is_alive : bool : get = _is_alive

var attack : int : get = get_attack

var _attack_cache : int

var defense : int : get = get_defense

var _defense_cache : int

var stamina : int : get = get_stamina

var _stamina_cache : int

func _init(base_stat_data : CharacterBaseStats) -> void:
	base_stats = base_stat_data
	_max_health_cache = base_stats._get_max_health()
	_health_cache = _max_health_cache
	change_level(0)

#region level up handling

func change_level(new_level : int) -> void:
	level = new_level
	update_stats()

func update_stats() -> void:
	var health_percentage : float = _health_cache as float / _max_health_cache
	_max_health_cache = logistic(level, base_stats.growth_mutliplier, base_stats.health, base_stats.max_health)
	_health_cache = (_max_health_cache * health_percentage) as int
	_attack_cache = logistic(level, base_stats.growth_mutliplier, base_stats.attack, base_stats.max_attack)
	_defense_cache = logistic(level, base_stats.growth_mutliplier, base_stats.defense, base_stats.max_defense)
	_stamina_cache = logistic(level, base_stats.growth_mutliplier, base_stats.stamina, base_stats.max_stamina)

#endregion

#region stat getters

func get_max_health() -> int:
	return _max_health_cache

func get_health() -> int:
	return _health_cache

func get_attack() -> int:
	return _attack_cache

func get_defense() -> int:
	return _defense_cache

func get_stamina() -> int:
	return _stamina_cache

#endregion

#region health handling

func deplete_health_by(damage_value : int) -> int:
	var damage_calculated : int = max(0, damage_value - _defense_cache)
	_health_cache = max(0, _health_cache - damage_calculated)
	return damage_calculated

func heal_by(healing_value : int) -> void:
	_health_cache = min(_max_health_cache, _health_cache, healing_value)

func _is_alive() -> bool:
	return _health_cache > 0

#endregion

func logistic(x : int, growth_multiplier : float, base_value : int, max_value : int) -> int:
	var growth : float = max_value * growth_multiplier
	var offset : float = log(growth / base_value - 1)
	var coefficient : float = (log(growth / max_value - 1) - offset) / 100
	return round(growth / (1 + exp(coefficient * x + offset))) as int

func _to_string() -> String:
	var has_class_name : bool = base_stats and base_stats.character_class_name and len(base_stats.character_class_name) > 0
	var has_character_name : bool = name and len(name) > 0
	if has_class_name and has_character_name:
		return "%s %s" % [base_stats.character_class_name, name]
	elif has_class_name or has_character_name:
		return name if has_character_name else base_stats.character_class_name
	else:
		return "???"
