extends Resource

class_name MoveAction

enum Targeting_Type {SELF, FRONT, LINEAR, AREA_OF_EFFECT}

var targeting : Targeting_Type : get = _get_targeting

@export var move_effect : MoveEffect

func _get_targeting() -> Targeting_Type:
    return Targeting_Type.SELF