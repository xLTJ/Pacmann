extends CharacterBody2D

@onready var main_screen = get_parent().get_parent()
@onready var hud = main_screen.find_child("HUD")

@export var ObstacleTileMap: TileMap
@onready var player_sprite = $AnimatedSprite2D
@export var speed = 5

const tile_size = 32

var is_moving = false
var has_powerup = 'none'

var movement_progress = 0.0

var start_position = Vector2(0, 0)
var movement_vector = Vector2(0, 0)
var movement_direction = 'right'
var grid_coordinates = Vector2(0, 0)
var last_coordinates


func _ready():
	start_position = position
	grid_coordinates = get_coordinates()
	player_sprite.play()


func _physics_process(delta):
	grid_coordinates = get_coordinates()
	player_input()
	if !is_moving:
		update_direction()
		last_coordinates = grid_coordinates
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

##########################################
# Items collection and hitting enemies
##########################################


# Executes when the player hits another body. Every body type has a variable called "entity_type" that stores what the body is, and then another function is executed based on this.
func _on_area_2d_body_entered(body):
	match body.entity_type:
		"cow":
			hit_cow(body)
		"skibid_point":
			collect_skibid_point(body)
		"skibid_ball":
			collect_skibid_ball(body)
		"speed_powerup":
			collect_speed(body)


# Function for when the player hits a cow
func hit_cow(body):
	if body.is_weak == true:
		kill_cow(body)
		return
	
	kill_player(body)


# When the player dies the game just restarts for now. Can be changed to whatever.
func kill_player(body):
	get_tree().reload_current_scene()


# When the cow dies it gets restarted in the main_screen scene.
func kill_cow(body):
	main_screen.restart_enemy(body.enemy_id)
	main_screen.award_points(200)


# When a skibid point is hit, the player is awarded points and the bodt is removed.
func collect_skibid_point(body):
	main_screen.award_points(body.points_awarded)
	main_screen.items_left -= 1
	
	body.queue_free()


# When a skibid_ball is collected a timer starts, and the function "pickup_powerup" is called on the main_screen scene. That function handles what happends to other entities than the player.
# After that the body is removed.
func collect_skibid_ball(body):
	$skibid_ball_timer.start()
	has_powerup = 'skibid_ball'
	
	main_screen.award_points(body.points_awarded)
	main_screen.items_left -= 1
	main_screen.pickup_powerup('skibid_ball')
	
	hud.find_child("powerup").text = "skibid ball"
	
	body.queue_free()


# When the timer for the skibid_ball powerup runs out the 
func _on_skibid_ball_timer_timeout():
	has_powerup = 'none'
	hud.find_child("powerup").text = "no powerup"
	main_screen.powerup_runout('skibid_ball')


# When a speed poweruo is collected a timer starts, and the players speed is increased. The "pickup_powerup" is not called as this only effects the player. After that the bodt is removed
func collect_speed(body):
	$speed_timer.start()
	has_powerup = 'speed_powerup'
	
	main_screen.award_points(body.points_awarded)
	main_screen.items_left -= 1
	speed = body.speed_boost
	
	hud.find_child("powerup").text = "speed"
	
	body.queue_free()

# once the timer for the speed powerup runs out, the players speed resets.
func _on_speed_timer_timeout():
	speed = 5
