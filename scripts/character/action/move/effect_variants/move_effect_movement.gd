extends MoveEffect

class_name MoveEffectMovement

@export var movement_targeting : Targeting_Type = Targeting_Type.SELF

@export var tiles_moved : int = 1

@export var pierce_occupied : bool = false

func _get_targeting() -> Targeting_Type:
	return movement_targeting

func _get_effect() -> Type_Effect:
	return Type_Effect.MOVEMENT
