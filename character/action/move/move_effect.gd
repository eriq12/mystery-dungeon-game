extends Resource

class_name Move_Effect

enum Targeting_Type {NONE=-1, SELF, AREA_OF_EFFECT, RANGED}

enum Type_Effect {NONE=-1, MOVEMENT, HEALTH_EFFECT, STATUS, TERRAIN}

@export var targeting : Targeting_Type : get = _get_targeting

@export var type_effect : Type_Effect : get = _get_effect

func _get_targeting() -> Targeting_Type:
    return Targeting_Type.NONE

func _get_effect() -> Type_Effect:
    return Type_Effect.NONE