extends Resource

class_name CharacterStats

@export var base_stats : CharacterBaseStats

@export var level : int = 0

var health : int : get = get_health

var _health_cache : int

var attack : int : get = get_attack

var _attack_cache : int

var defense : int : get = get_defense

var _defense_cache : int

var stamina : int : get = get_stamina

var _stamina_cache : int

func _init(base_stat_data : CharacterBaseStats) -> void:
	base_stats = base_stat_data
	change_level(0)

func change_level(new_level : int) -> void:
	level = new_level
	update_stats()

func update_stats() -> void:
	_health_cache = logistic(level, base_stats.growth_mutliplier, base_stats.health, base_stats.max_health)
	_attack_cache = logistic(level, base_stats.growth_mutliplier, base_stats.attack, base_stats.max_attack)
	_defense_cache = logistic(level, base_stats.growth_mutliplier, base_stats.defense, base_stats.max_defense)
	_stamina_cache = logistic(level, base_stats.growth_mutliplier, base_stats.stamina, base_stats.max_stamina)

func get_health() -> int:
	return _health_cache

func get_attack() -> int:
	return _attack_cache

func get_defense() -> int:
	return _defense_cache

func get_stamina() -> int:
	return _stamina_cache

func logistic(x : int, growth_multiplier : float, base_value : int, max_value : int) -> int:
	var growth : float = max_value * growth_multiplier
	var offset : float = log(growth / base_value - 1)
	var coefficient : float = (log(growth / max_value - 1) - offset) / 100
	return round(growth / (1 + exp(coefficient * x + offset))) as int
