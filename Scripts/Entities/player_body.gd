extends CharacterBody2D

@export var ObstacleTileMap: TileMap

@onready var player_sprite = $AnimatedSprite2D

@export var speed = 5
const tile_size = 32

var is_moving = false
var movement_progress = 0.0

var start_position = Vector2(0, 0)
var movement_vector = Vector2(0, 0)
var movement_direction = 'right'
var grid_coordinates = Vector2(0, 0)

func _ready():
	start_position = position
	grid_coordinates = get_coordinates()
	player_sprite.play()
	# print(ObstacleTileMap.get_cell_source_id(0, Vector2i(0,0)))


func _physics_process(delta):
	grid_coordinates = get_coordinates()
	player_input()
	if !is_moving:
		update_direction()
	if movement_vector  != Vector2.ZERO:
		move_player(delta)
	else:
		is_moving = false


func player_input():
	if Input.is_action_just_pressed("ui_down"):
		print('down')
		movement_direction = 'down'
	elif Input.is_action_just_pressed("ui_up"):
		print('up')
		movement_direction = 'up'
	elif Input.is_action_just_pressed("ui_left"):
		print('left')
		movement_direction = 'left'
	elif Input.is_action_just_pressed("ui_right"):
		print('right')
		movement_direction = 'right'


func move_player(delta):
	movement_progress += speed * delta
	if movement_progress >= 1.0:
		position = start_position + (tile_size * movement_vector)
		movement_progress = 0.0
		is_moving = false
	else:
		position = start_position + (movement_progress * movement_vector * tile_size)

func update_direction():
	match movement_direction:
		'down':
			var bottom_tile = ObstacleTileMap.get_neighbor_cell(grid_coordinates, TileSet.CELL_NEIGHBOR_BOTTOM_SIDE)
			if (ObstacleTileMap.get_cell_source_id(0, bottom_tile)) == -1:
				movement_vector = Vector2.ZERO
				movement_vector.y = 1
				player_sprite.flip_h = movement_vector.x < 0
				player_sprite.rotation_degrees = 90
		'up':
			var top_tile = ObstacleTileMap.get_neighbor_cell(grid_coordinates, TileSet.CELL_NEIGHBOR_TOP_SIDE)
			if (ObstacleTileMap.get_cell_source_id(0, top_tile)) == -1:
				movement_vector = Vector2.ZERO
				movement_vector.y = -1
				player_sprite.flip_h = movement_vector.x < 0
				player_sprite.rotation_degrees = 270
		'right':
			var right_tile = ObstacleTileMap.get_neighbor_cell(grid_coordinates, TileSet.CELL_NEIGHBOR_RIGHT_SIDE)
			if (ObstacleTileMap.get_cell_source_id(0, right_tile)) == -1:
				player_sprite.rotation_degrees = 0
				movement_vector = Vector2.ZERO
				movement_vector.x = 1
				player_sprite.flip_h = movement_vector.x < 0
		'left':
			var left_tile = ObstacleTileMap.get_neighbor_cell(grid_coordinates, TileSet.CELL_NEIGHBOR_LEFT_SIDE)
			if (ObstacleTileMap.get_cell_source_id(0, left_tile)) == -1:
				player_sprite.rotation_degrees = 0
				movement_vector = Vector2.ZERO
				movement_vector.x = -1
				player_sprite.flip_h = movement_vector.x < 0
	
	collision()
	start_position = position
	is_moving = true


func sprite_direction():
	player_sprite.flip_h = movement_vector.x < 0
	if movement_vector.y == 1:
		player_sprite.rotation_degrees = 90

func get_coordinates():
	var player_coordinates = (position / tile_size)
	player_coordinates.x -= 0.5
	player_coordinates.y -= 0.5
	return player_coordinates

func collision():
	if movement_vector.y == -1:
		var top_tile = ObstacleTileMap.get_neighbor_cell(grid_coordinates, TileSet.CELL_NEIGHBOR_TOP_SIDE)
		if (ObstacleTileMap.get_cell_source_id(0, top_tile)) == 1:
			movement_vector.y = 0
	if movement_vector.y == 1:
		var bottom_side = ObstacleTileMap.get_neighbor_cell(grid_coordinates, TileSet.CELL_NEIGHBOR_BOTTOM_SIDE)
		if (ObstacleTileMap.get_cell_source_id(0, bottom_side)) == 1:
			movement_vector.y = 0

	if movement_vector.x == -1:
		var left_tile = ObstacleTileMap.get_neighbor_cell(grid_coordinates, TileSet.CELL_NEIGHBOR_LEFT_SIDE)
		if (ObstacleTileMap.get_cell_source_id(0, left_tile)) == 1:
			movement_vector.x = 0
	if movement_vector.x == 1:
		var right_tile = ObstacleTileMap.get_neighbor_cell(grid_coordinates, TileSet.CELL_NEIGHBOR_RIGHT_SIDE)
		if (ObstacleTileMap.get_cell_source_id(0, right_tile)) == 1:
			movement_vector.x = 0
