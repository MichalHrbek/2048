extends Node2D

@export var minimal_swipe_distance: float = 100
@export var maximal_directional_offset: float = deg_to_rad(25)
@export var register_mouse: bool = true
var _start_pos: Vector2

signal swiped(start: Vector2, end: Vector2)
signal directional_swiped(dir: Vector2i)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch or (register_mouse and event is InputEventMouseButton):
		if event.pressed:
			_start_pos = event.position
		else:
			var delta: Vector2 = event.position-_start_pos
			if delta.length() > minimal_swipe_distance:
				swiped.emit(_start_pos, event.position)
				var dir = delta.normalized()
				for i in [Vector2.UP, Vector2.DOWN, Vector2.LEFT, Vector2.RIGHT]:
					if abs(dir.angle_to(i)) < maximal_directional_offset:
						directional_swiped.emit(Vector2i(i))
