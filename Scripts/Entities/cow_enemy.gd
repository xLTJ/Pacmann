extends CharacterBody2D

@onready var a_star_script = get_node("/root/A_star_script")


@export var entity_type = "cow"
var enemy_id = 0
var pathfinding_mode = 'dynamic'

@export var speed = 3
@export var transition_time = 2
@export var obstacle_tileMap: TileMap
@onready var tilemap_rect = obstacle_tileMap.get_used_rect().size
@onready var player
var columns
var rows
var grid = []

const tile_size = 32

var grid_coordinates = Vector2(0, 0)
var start_position = Vector2(0, 0)
var new_position = Vector2(0, 0)
var initial_coordinates = Vector2(0, 0)

var movement_vector = Vector2(0, 0)

var is_moving = false
var is_weak = false
var is_transitioning = false
var is_on_route = false
var movement_progress = 0.0

var cow_path = Vector2(0, 0)

func _ready():
	start_position = position
	initial_coordinates = grid_coordinates
	grid = get_all_cells()
	print(player)


func _physics_process(delta):
	grid_coordinates = get_coordinates()
	if !is_moving:
		cow_path = get_enemy_path()
		update_target_position(cow_path)
	move_to_cell(new_position, delta)


# Gets the cows current coordinates on the tilemap, based on its position.
func get_coordinates():
	var cow_coordinates = (position / tile_size)
	cow_coordinates.x -= 0.5
	cow_coordinates.y -= 0.5
	return cow_coordinates


# Gets the path that the cow should follow based on its pathfinding mode.
func get_enemy_path():
	cow_path = pathfinding(grid_coordinates, player.last_coordinates, pathfinding_mode)
	if not cow_path:
		cow_path = get_enemy_path()
	if len(cow_path) < 2 && cow_path:
			is_on_route = false
	
	return cow_path


# Updates the cell that the cow should move towards. This cell is the first in the "path" array. After this cell has been set the cell is removed from the array.
func update_target_position(path):
	new_position = (path[0])
	is_moving = true
	path.pop_front()
	movement_vector = new_position - start_position


# Moves the cow towards the target cell based on the coordinates provided.
func move_to_cell(coordinates, delta):
	movement_progress += speed * delta
	if movement_progress >= 1.0:
		position = start_position * tile_size + (tile_size * movement_vector) + (Vector2(tile_size / 2, tile_size / 2))
		movement_progress = 0.0
		is_moving = false
		start_position = coordinates;
	else:
		position = start_position * tile_size + (movement_progress * movement_vector * tile_size)  + (Vector2(tile_size / 2, tile_size / 2))


# Checks available movement directions for the cow
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


# Gets the cell id for every cell in the obstacle tilemap
func get_all_cells():
	var grid_ids = []
	rows = tilemap_rect.y
	columns = tilemap_rect.x
	for row in range(rows):
		grid_ids.append([])
		for column in range(columns):
			var cell_id = Vector2(column, row)
			grid_ids[row].append(obstacle_tileMap.get_cell_source_id(0, cell_id))
	
	return grid_ids


# Makes the cow weak and changes its appearance
func weak_cow():
	is_weak = true
	$EvilCowWeak.show()
	if is_transitioning:
		is_transitioning = false
		$EvilCowTransition.hide()


# Starts a transition-phrase where the cow changes its outline to show that its about to turn back. After the timer ends, the cow is reverted back to its normal unweak state.
func unweak_cow():
	if !is_weak:
		return
	is_transitioning = true
	$EvilCowTransition.show()
	await get_tree().create_timer(2).timeout
	if is_transitioning:
		is_weak = false
		$EvilCowWeak.hide()
		$EvilCowTransition.hide()


# Handles the different pathfinding modes for the cow.
func pathfinding(start, destination, mode):
	match mode:
		'shortest_path':
			return shortest_path(start, destination)
		'random_cell':
			return random_cell()
		'near_player':
			return near_player(start, destination, 5)
		'dynamic':
			var distance_to_player = grid_coordinates.distance_to(player.grid_coordinates)
			if distance_to_player > 6:
				if is_on_route && cow_path:
					return cow_path
				
				is_on_route = true
				return near_player(start, destination, int(distance_to_player))
			else:
				is_on_route = false
				return shortest_path(start, destination)


# A* pathfinding the the shortest path directly towards the player.
func shortest_path(start, destination):
	return a_star_script.a_star(grid, start, destination, rows, columns)


# Choses a random cell bordering the one the cow occupies and returns those coordinates.
func random_cell():
	var available_directions = get_available_directions()
	var chosen_direction = available_directions.pick_random()
	var path = [chosen_direction + grid_coordinates]
	return path


# Gets a random tile withing a certain radius around the player and uses the A* algoritm to find the shortest path towards this cell.
func near_player(start, destination, radius):
	var near_destination = find_random_tile_in_radius(destination, radius)
	return a_star_script.a_star(grid, start, near_destination, rows, columns)


# Find a random unblocked tile withing a certain radius around the player.
func find_random_tile_in_radius(center, radius):
	print(center)
	if center == Vector2(4, 16) || center == Vector2(3, 16):
		pass
	var unblocked_tiles = []
	
	for row in range(center.y - radius, center.y + radius + 1):
		if row not in range(tilemap_rect.y - 1):
			continue
			
		for column in range(center.x - radius, center.x + radius + 1):
			if column not in range(tilemap_rect.x - 1):
				continue
				
			var random_tile = grid[row][column]
			
			if random_tile != 1 && random_tile != 0:
				unblocked_tiles.append(Vector2(column, row))
	
	var chosen_tile = unblocked_tiles[randi() % unblocked_tiles.size()]
	# print("chosen tile: " + str(chosen_tile))
	return chosen_tile

