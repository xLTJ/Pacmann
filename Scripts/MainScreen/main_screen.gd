extends Node2D
@export var cow_instance: PackedScene
@export var player_instance: PackedScene
@onready var tile_size = 32

@onready var current_level = 0

@onready var current_level_node = $current_level

var obstacle_tileMap: TileMap
var item_spawn_tilemap: TileMap
var current_level_scene

var player_points = 0


# Called when the node enters the scene tree for the first time.
func _ready():
	next_level()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

###################################
# Transitions to next level
###################################
func next_level():
	if current_level_scene:
		for child in current_level_node.get_children():
			child.queue_free()
	
	add_next_scene()
	add_skibid_points()
	restart_player()
	add_enemies()
	item_spawn_tilemap.hide()

# Handles the new levels map
func add_next_scene():
	current_level += 1
	current_level_scene = load("res://Scenes/Screens/Levels/level_" + str(current_level) + ".tscn").instantiate()
	current_level_node.add_child(current_level_scene)
	
	obstacle_tileMap = current_level_scene.find_child("ObstacleMap")
	item_spawn_tilemap = current_level_scene.find_child("SpawnMap")

# Restarts the player for the new map
func restart_player():
	var player = player_instance.instantiate()
	player.ObstacleTileMap = obstacle_tileMap
	
	var player_coordinates = current_level_scene.player_spawn_coordinates
	player.position = coordinates_to_position(player_coordinates)
	
	current_level_node.add_child(player)

# Adds enemies for the new map
func add_enemies():
	var enemies_coordinates = current_level_scene.enemy_coordinates
	
	for coordinate in enemies_coordinates:
		add_enemy(coordinate)

# Function for adding enemies
func add_enemy(coordinates):
	var cow = cow_instance.instantiate()
	cow.grid_coordinates = coordinates
	cow.position = coordinates_to_position(coordinates)

	cow.obstacle_tileMap = obstacle_tileMap
	
	current_level_node.add_child(cow)

func add_skibid_points():
	var skibid_point_coordinates = current_level_scene.skibid_points_coordinates
	
	for coordinate in skibid_point_coordinates:
		add_skibid_point(coordinate)

func add_skibid_point(coordinate):
	var skibid_point = load("res://Scenes/Items/skibid_point.tscn").instantiate()
	skibid_point.position = coordinates_to_position(coordinate)
	
	current_level_node.add_child(skibid_point)

###################################
# Helper functions
###################################

func coordinates_to_position(coordinates):
	return coordinates * tile_size + Vector2(tile_size / 2, tile_size / 2)
