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
	if 1 != 2:
		print('yes')
		


func _physics_process(delta):
	grid_coordinates = get_coordinates()
	player_input()
	if !is_moving:
		update_direction()
	move_player(delta)


# handles player input
func player_input():
	if Input.is_action_just_pressed("ui_down"):
		movement_direction = 'down'
	elif Input.is_action_just_pressed("ui_up"):
		movement_direction = 'up'
	elif Input.is_action_just_pressed("ui_left"):
		movement_direction = 'left'
	elif Input.is_action_just_pressed("ui_right"):
		movement_direction = 'right'


# Moves the player
func move_player(delta):
	movement_progress += speed * delta
	if movement_progress >= 1.0:
		position = start_position + (tile_size * movement_vector)
		movement_progress = 0.0
		is_moving = false
	else:
		position = start_position + (movement_progress * movement_vector * tile_size)


# Updates the players direction based on the players input, and makes sure that the direction first actually changes when the tile is available
func update_direction():
	match movement_direction:
		'down':
			update_movement(Vector2(0, 1), 90, 4)
		'up':
			update_movement(Vector2(0, -1), 270, 12)
		'right':
			update_movement(Vector2(1, 0), 0, 0)
		'left':
			update_movement(Vector2(-1, 0), 0, 8)
			
	
	collision()
	start_position = position
	is_moving = true


# Updates the player movement based on the direction
func update_movement(new_vector, rotation, direction_id):
	var neighbor_cell = ObstacleTileMap.get_neighbor_cell(grid_coordinates, direction_id)
	
	if ObstacleTileMap.get_cell_source_id(0, neighbor_cell) == -1:
		movement_vector = new_vector
		player_sprite.flip_h = movement_vector.x < 0
		player_sprite.rotation_degrees = rotation


# Gets the grid coordinates of the player
func get_coordinates():
	var player_coordinates = (position / tile_size)
	player_coordinates.x -= 0.5
	player_coordinates.y -= 0.5
	return player_coordinates


# Handles collision checks
func collision():
	check_collision(Vector2(0, -1), TileSet.CELL_NEIGHBOR_TOP_SIDE)
	check_collision(Vector2(0, 1), TileSet.CELL_NEIGHBOR_BOTTOM_SIDE)
	check_collision(Vector2(-1, 0), TileSet.CELL_NEIGHBOR_LEFT_SIDE)
	check_collision(Vector2(1, 0), TileSet.CELL_NEIGHBOR_RIGHT_SIDE)


# Checks the collision in a specific direction
func check_collision(direction, neighbor_type):
	if movement_vector == direction:
		var neighbor_cell = ObstacleTileMap.get_neighbor_cell(grid_coordinates, neighbor_type)
		if ObstacleTileMap.get_cell_source_id(0, neighbor_cell) == 1:
			movement_vector = Vector2.ZERO
