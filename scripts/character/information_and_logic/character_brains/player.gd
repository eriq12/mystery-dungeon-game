extends CharacterBrain

class_name PlayerBrain

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta : float) -> void:
	var new_direction : TileMapLevel.Direction = TileMapLevel.Direction.NONE
	if Input.is_action_pressed("game_up"):
		new_direction = TileMapLevel.Direction.NORTH
	elif Input.is_action_pressed("game_right"):
		new_direction = TileMapLevel.Direction.EAST
	elif Input.is_action_pressed("game_down"):
		new_direction = TileMapLevel.Direction.SOUTH
	elif Input.is_action_pressed("game_left"):
		new_direction = TileMapLevel.Direction.WEST
	else:
		set_queued_move(null)
		set_queued_direction()
	if not new_direction == TileMapLevel.Direction.NONE:
		if new_direction == orientation:
			set_queued_move(Library.basic_move)
		else:
			set_queued_move(Library.basic_face)
			set_queued_direction(new_direction)

