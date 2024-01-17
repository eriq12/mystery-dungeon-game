extends Resource

class_name MoveEffect

enum Type_Effect {NONE=-1, MOVEMENT, ORIENT, HEALTH_EFFECT, STATUS, TERRAIN}

var type_effect : Type_Effect : get = _get_effect

func _get_effect() -> Type_Effect:
    return Type_Effect.NONE