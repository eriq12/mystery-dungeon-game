extends MoveEffect

class_name MoveEffectDamage

@export var damage_value : int

func _get_effect() -> Type_Effect:
    return Type_Effect.HEALTH_EFFECT