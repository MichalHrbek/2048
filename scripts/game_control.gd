extends Control

@onready var game: Game2048 = %Game

func set_width(value: float):
	game.width = int(value)
	game.restart()
	grab_focus()

func set_height(value: float):
	game.height = int(value)
	game.restart()
	grab_focus()
