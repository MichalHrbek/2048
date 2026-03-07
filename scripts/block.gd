class_name Block2048
extends Sprite2D

var value := 2
@export var _label: Label

@onready var _move_tween: Tween


func _set_color(color: Color) -> void:
	self_modulate = color

func set_value(n: int) -> void:
	value = n
	if _label:
		_label.text = str(n) if n else ""
	_set_color(Palette2048.get_color(n))

func _ready() -> void:
	set_value(value)

func goto_pos(goal: Vector2, duration: float, die_after: bool = false) -> void:
	if _move_tween:
		_move_tween.kill()
	
	if duration:
		_move_tween = create_tween()
		_move_tween.tween_property(self, "position", goal, duration)
		if die_after:
			_move_tween.tween_callback(die)
			z_index -= 1
	else:
		position = goal
		if die_after: die()

func die() -> void:
	queue_free()
