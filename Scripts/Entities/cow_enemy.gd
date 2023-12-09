extends CharacterBody2D

@export var entity_type = "cow"

@export var speed = 3
@export var obstacle_tileMap: TileMap

const tile_size = 32

var grid_coordinates = Vector2(0, 0)
var start_position = Vector2(0, 0)
var new_position = Vector2(0, 0)
var movement_vector = Vector2(0, 0)

var is_moving = false
var movement_progress = 0.0

var cow_path = Vector2(0, 0)

func _ready():
	start_position = position
	#start_position = Vector2(tile_size * 4, tile_size * 2)
	#position = start_position
	# grid_coordinates = get_coordinates()
	# cow_path = Vector2(3, 1)


func _physics_process(delta):
	grid_coordinates = get_coordinates()
	if !is_moving:
		cow_path = get_enemy_path()
		update_target_position(cow_path)
	move_to_cell(new_position, delta)


func get_coordinates():
	var cow_coordinates = (position / tile_size)
	cow_coordinates.x -= 0.5
	cow_coordinates.y -= 0.5
	return cow_coordinates


func get_enemy_path():
	# var cow_path = [Vector2(3,1), Vector2(3, 2), Vector2(3, 1), Vector2(3, 2), Vector2(3, 3), Vector2(4, 3), Vector2(4, 4), Vector2(4, 5), Vector2(5, 5)]
	var available_directions = get_available_directions()
	var chosen_direction = available_directions.pick_random()
	var cow_path = [chosen_direction + grid_coordinates]
	return cow_path


func update_target_position(path):
	new_position = (path[0])
	is_moving = true
	path.pop_front()
	movement_vector = new_position - start_position


func move_to_cell(coordinates, delta):
	movement_progress += speed * delta
	if movement_progress >= 1.0:
		position = start_position * tile_size + (tile_size * movement_vector) + (Vector2(tile_size / 2, tile_size / 2))
		movement_progress = 0.0
		is_moving = false
		start_position = coordinates;
	else:
		position = start_position * tile_size + (movement_progress * movement_vector * tile_size)  + (Vector2(tile_size / 2, tile_size / 2))


func get_available_directions():
	var available_directions = []
	if check_collision(Vector2(0, -1), TileSet.CELL_NEIGHBOR_TOP_SIDE):
		available_directions.append(Vector2(0, -1))
	if check_collision(Vector2(0, 1), TileSet.CELL_NEIGHBOR_BOTTOM_SIDE):
		available_directions.append(Vector2(0, 1))
	if check_collision(Vector2(-1, 0), TileSet.CELL_NEIGHBOR_LEFT_SIDE):
		available_directions.append(Vector2(-1, 0))
	if check_collision(Vector2(1, 0), TileSet.CELL_NEIGHBOR_RIGHT_SIDE):
		available_directions.append(Vector2(1, 0))
	
	return available_directions


# Checks the collision in a specific direction
func check_collision(direction, neighbor_type):
	var neighbor_cell = obstacle_tileMap.get_neighbor_cell(grid_coordinates, neighbor_type)
	if obstacle_tileMap.get_cell_source_id(0, neighbor_cell) == 1:
		return false
	else:
		return true

func get_random_cell():
	pass



#func _on_area_2d_body_entered(body):
#	print("player died")
#	kill_player(body)

#func kill_player(body):
#	get_tree().reload_current_scene()
