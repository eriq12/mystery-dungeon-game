extends MoveAction

class_name LinearAction

@export_range(1,10) var reach : int

@export_range(0,4) var pierce : int

@export var target_characters : bool

func _get_targeting() -> Targeting_Type:
    return Targeting_Type.LINEAR