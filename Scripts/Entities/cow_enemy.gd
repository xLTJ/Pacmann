extends CharacterBody2D

@export var entity_type = "cow"

@export var speed = 3
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
var movement_vector = Vector2(0, 0)

var is_moving = false
var movement_progress = 0.0

var cow_path = Vector2(0, 0)

func _ready():
	start_position = position
	grid = get_all_cells()
	print(player)
	# cow_path = get_enemy_path()
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
	# var available_directions = get_available_directions()
	# var chosen_direction = available_directions.pick_random()
	cow_path = pathfinding(grid_coordinates, player.last_coordinates)
	return cow_path


func update_target_position(path):
	print(path)
	new_position = (path[1])
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

func get_all_cells():
	var grid_ids = []
	rows = tilemap_rect.x
	columns = tilemap_rect.y
	for x in range(rows):
		grid_ids.append([])
		for y in range(columns):
			var cell_id = Vector2(y, x)
			grid_ids[x].append(obstacle_tileMap.get_cell_source_id(0, cell_id))
	
	print(grid_ids)
	return grid_ids


func pathfinding(start, destination):
	# All coordinates are by (x, y) or (column, row) starting from 0
	return a_star(grid, start, destination)

# First we make a class for the cells
class a_star_node:
	var f
	var g
	var h
	var closed
	var parent_x
	var parent_y
	
	func _init(f, g, h, closed):
		self.f = f
		self.g = g
		self.h = h
		self.closed = closed
		self.parent_x = 0
		self.parent_y = 0

	func update_values(f, g, h):
		self.f = f
		self.g = g
		self.h = h

	func get_values():
		return [self.f, self.g, self.h]

	func close():
		self.closed = true

	func update_parents(parent_node_coords):
		self.parent_x = parent_node_coords[0]
		self.parent_y = parent_node_coords[1]

	func get_parent():
		return [self.parent_x, self.parent_y]


# Finds the h value for a cell based on its coordinates using Euclidean distance
func get_h_value(cell_coords, destination_coords):
	return sqrt(pow((cell_coords.x - destination_coords.x), 2) + pow((cell_coords.y - destination_coords.y), 2))


# Checks if a cell is inside the grid
func is_in_grid(cell_coords):
	var x_coords = cell_coords.x
	var y_coords = cell_coords.y
	return (0 <= x_coords) && (x_coords < rows) && (0 <= y_coords) && (y_coords < columns)


# Checks if cell is blocked
func is_cell_blocked(cell_coords, grid_list):
	var cell_column = cell_coords.x
	var cell_row = cell_coords.y
	var blocked = bool((grid_list[cell_row][cell_column]) == 1)
	var testtest = grid_list[cell_row][cell_column]
	return bool((grid_list[cell_row][cell_column]) == 1)


# Checks if the cell is the destination cell
func is_destination(cell_coords, destination):
	return cell_coords == destination


# gets node based on coordinates so that I don't have to think about switching the values every time
func get_a_star_node(node_list, node_coords):
	return node_list[node_coords.y][node_coords.x]


func a_star(grid_list, source, destination):
	var node_info = []

	# Every node starts out with having each value be infinitely big until they are found
	# The node info also contains whether a node is in the closed list or not, thus also serving as the closed list
	for row in grid_list:
		node_info.append([])
		for node in range(row.size()):
			node_info[-1].append(a_star_node.new(INF, INF, INF, false))

	# The start node values are set to 0
	get_a_star_node(node_info, source).update_values(0, 0, 0)

	# Then we initialize the open list and add the source node as the first node
	var open_list = []
	var source_f = get_a_star_node(node_info, source).f
	# I'll be storing each node as a tuple, with the first value being the f value
	# The second value is the node coordinates that can be used to access the node information
	open_list.append([source_f, source])

	while open_list.size() > 0:
		# Sets the node to be explored to the next node in the open list and removes it from the list.
		var next_node = open_list.pop_front()
		
		if is_destination(next_node[1], destination):
			print('waow, found destination')
			return show_path(next_node, node_info, source)
		
		var next_node_info = get_a_star_node(node_info, next_node[1])
		
		var node_x = next_node[1].x
		var node_y = next_node[1].y
		
		# Now we have to get the 8 adjacent nodes to this node. We do this the following way:
		# We have the current cell (m) as well as all the adjacent cells
		
		# [UL][U][UR]
		# [L] [M] [R]
		# [BL][B][BR]
		
		# M = Current node being explored (x (node_x), y (node_y))
		# U = Up (x, y-1)
		# L = Left (x-1, y)
		# R = Right (x+1, y)
		# B = Bottom (x, y+1)
		
		# Now we have to get the 4 adjacent nodes to this node. We do this the following way:
		# We have the current cell (m) as well as all the adjacent cells
		find_successor(node_x, node_y - 1, node_info, open_list, next_node, destination, grid_list)  # U
		find_successor(node_x - 1, node_y, node_info, open_list, next_node, destination, grid_list)  # L
		find_successor(node_x + 1, node_y, node_info, open_list, next_node, destination, grid_list)  # R
		find_successor(node_x, node_y + 1, node_info, open_list, next_node, destination, grid_list)  # B
		
		# Adds the node to the closed list
		next_node_info.close()
		get_current_grid(grid, node_info)
		# yield(get_tree().create_timer(0.5), "timeout")

	print('there is no path to the destination')


func find_successor(x, y, node_info, open_list, parent_node, destination, grid_list):
	# If the node is outside the grid, is blocked, or is in the closed list it gets skipped
	if not is_in_grid(Vector2(x, y)):
		return

	var selected_node = get_a_star_node(node_info, Vector2(x, y))
	var parent_node_info = get_a_star_node(node_info, parent_node[1])

	if is_cell_blocked(Vector2(x, y), grid_list) or selected_node.closed:
		return

	var node_g = parent_node_info.g
	var node_h = get_h_value(Vector2(x, y), destination)
	var node_f = node_h + node_g

	# Checks if the new f value is smaller than whatever f value was there before.
	# If it isn't, the path isn't the shortest and there's no reason to push it to the open list
	if node_f < selected_node.f:
		selected_node.update_values(node_f, node_g, node_h)
		selected_node.update_parents(parent_node[1])

		# If there is nothing in the open list, the node is just added directly
		if open_list.size() == 0:
			open_list.append([node_f, Vector2(x, y)])
			return

		# If there is any other nodes in the open list, the new node is inserted based on the f value
		var i = 0
		for node in open_list:
			if node[0] > node_f:
				open_list.insert(i, [node_f, Vector2(x, y)])
				return
			i += 1

		open_list.append([node_f, Vector2(x, y)])


func get_current_grid(grid_list, grid_info):
	var j = 0
	var temp_grid = []
	for row in grid_list:
		var k = 0
		var temp_row = row
		for item in temp_row:
			if grid_info[j][k].closed:
				temp_row[k] = 5
			k += 1
		j += 1
		temp_grid.append(temp_row)
	return temp_grid


func show_path(end_node, node_info, source):
	var path = []
	var node = end_node[1]
	path.insert(0, node)
	while not node == source:
		var current_node_info = get_a_star_node(node_info, node)
		var parent_node = current_node_info.get_parent()
		node.x = parent_node[0]
		node.y = parent_node[1]
		path.insert(0, node)

	print("final path is " + str(path))
	return path
