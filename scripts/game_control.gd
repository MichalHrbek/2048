extends Control

@onready var game: Game2048 = %Game

func _update_bbox():
	custom_minimum_size = game.get_bbox_size()

func _ready() -> void:
	game.game_started.connect(_update_bbox)
	_update_bbox()

func set_width(value: float):
	game.width = int(value)
	game.restart()
	grab_focus()

func set_height(value: float):
	game.height = int(value)
	game.restart()
	grab_focus()
