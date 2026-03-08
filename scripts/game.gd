class_name Game2048
extends Node2D

@export var width: int = 4
@export var height: int = 4
@export var block_size: Vector2 = Vector2(128, 128)
@export var spacing: Vector2 = Vector2(16, 16)
@export var empty_block_scene: PackedScene
@export var block_scene: PackedScene
@export var animation_duration: float = 0.1

signal game_lost
signal score_changed(new_score: int)
signal game_started

@onready var _background: ColorRect = %Background

var _offset := block_size*0.5+spacing
var _empty_blocks: Dictionary[Vector2i, Block2048] = {}
var _blocks: Dictionary[Vector2i, Block2048] = {}

var score: int = 0:
	set(value):
		score = value
		score_changed.emit(value)

func is_valid(coords: Vector2i) -> bool:
	return coords.x >= 0 and coords.y >= 0 and coords.x < width and coords.y < height

func get_center(coords: Vector2i) -> Vector2:
	return _offset+Vector2(coords)*(block_size+spacing)

func get_topleft(coords: Vector2i) -> Vector2:
	return _offset+Vector2(coords)*(block_size+spacing)-0.5*block_size

func get_bbox_size() -> Vector2:
	return _offset+Vector2(width, height)*(block_size+spacing)-0.5*block_size

func _gen_start_value() -> int:
	if randf() < 0.9:
		return 2
	return 4

func _spawn_random() -> bool:
	var b: Block2048 = block_scene.instantiate()
	b.set_value(_gen_start_value())
	
	var empty_spaces: Array[Vector2i] = []
	for x in range(width):
		for y in range(height):
			var c = Vector2i(x,y)
			if not _blocks.has(c):
				empty_spaces.append(c)
	
	if not empty_spaces:
		return false
	
	var c = empty_spaces.pick_random()
	b.position = get_center(c)
	add_child(b)
	_blocks[c] = b
	return true

func restart():
	_background.self_modulate = Palette2048.get_color(-1)
	
	for i in _blocks.values():
		i.queue_free()
	for i in _empty_blocks.values():
		i.queue_free()
	_blocks = {}
	_empty_blocks = {}
	score = 0

	for x in range(width):
		for y in range(height):
			var c = Vector2i(x,y)
			var b: Block2048 = empty_block_scene.instantiate()
			b.set_value(0)
			b.position = get_center(c)
			add_child(b)
			_empty_blocks[c] = b
	
	_spawn_random()
	_spawn_random()
	
	game_started.emit()

func _ready() -> void:
	restart()

func _iter(dir: Vector2i, main_axis_index: int, side_axis_index: int) -> Vector2i:
	var horiz: bool = dir in [Vector2i.RIGHT, Vector2i.LEFT]
	var side_axis_len = height if horiz else width
	var main_axis_len = width if horiz else height

	var c: Vector2i
	if dir.x + dir.y > 0:
		if horiz: c = Vector2i(main_axis_len-main_axis_index-1, side_axis_len-side_axis_index-1)
		else: c = Vector2i(side_axis_len-side_axis_index-1, main_axis_len-main_axis_index-1)
	else:
		if horiz: c = Vector2i(main_axis_index, side_axis_index)
		else: c = Vector2i(side_axis_index, main_axis_index)
	
	return c

func collapse(dir: Vector2i) -> bool:
	assert(dir in [Vector2i.RIGHT, Vector2i.LEFT, Vector2i.UP, Vector2i.DOWN])
	
	var moved := false
	var score_delta = 0

	var side_axis_len = height if dir in [Vector2i.RIGHT, Vector2i.LEFT] else width
	var main_axis_len = width if dir in [Vector2i.RIGHT, Vector2i.LEFT] else height
	
	for i in range(side_axis_len):
		for j in range(main_axis_len):
			for k in range(main_axis_len):
				var c = _iter(dir, j-k, i)
				if not _blocks.has(c):
					break
				
				var g = _iter(dir, j-k, i)+dir
				if is_valid(g):
					if _blocks.has(g):
						if _blocks[g].value == _blocks[c].value: # Two blocks merge
							_blocks[g].set_value(_blocks[g].value*2)
							_blocks[c].goto_pos(get_center(g), animation_duration, true)
							_blocks.erase(c)
							moved = true
							score_delta += _blocks[g].value
							# TODO: continue if combos are possible
						# Hit a block
						break
					# The space was empty -> moving into it
					_blocks[g] = _blocks[c]
					_blocks[g].goto_pos(get_center(g), animation_duration)
					_blocks.erase(c)
					moved = true
					continue
				# Hit a wall
				break
	
	score += score_delta
	return moved

func collapse_and_continue(dir: Vector2i):
	if collapse(dir):
		await get_tree().create_timer(animation_duration).timeout
		_spawn_random()
		
		if is_lost():
			game_lost.emit()

func is_lost() -> bool:
	for x in range(width):
		for y in range(height):
			var c = Vector2i(x,y)
			if not _blocks.has(c):
				return false
			else:
				for n in [Vector2i.RIGHT, Vector2i.LEFT, Vector2i.UP, Vector2i.DOWN]:
					if _blocks.has(c+n):
						if _blocks[c+n].value == _blocks[c].value:
							return false
	return true

func _unhandled_key_input(event: InputEvent) -> void:
	if Input.is_action_just_pressed_by_event("ui_right", event): collapse_and_continue(Vector2i.RIGHT)
	elif Input.is_action_just_pressed_by_event("ui_left", event): collapse_and_continue(Vector2i.LEFT)
	elif Input.is_action_just_pressed_by_event("ui_up", event): collapse_and_continue(Vector2i.UP)
	elif Input.is_action_just_pressed_by_event("ui_down", event): collapse_and_continue(Vector2i.DOWN)
