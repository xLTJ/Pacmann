extends Node2D
@export var cow_instance: PackedScene
@export var player_instance: PackedScene
@onready var tile_size = 32

@onready var current_level = 1

@onready var current_level_node = $current_level
@onready var hud = $HUD

var obstacle_tileMap: TileMap
var item_spawn_tilemap: TileMap
var current_level_scene

var player_points = 0
var items_left = 0
var player


# Called when the node enters the scene tree for the first time.
func _ready():
	load_level()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if items_left <= 0:
		current_level += 1
		load_level()


###################################
# Transitions to next level
###################################
func load_level():
	if current_level_scene:
		for child in current_level_node.get_children():
			child.queue_free()
	
	add_level_scene()
	add_item_type("skibid_point")
	add_item_type("skibid_ball")
	restart_player()
	add_enemies()
	item_spawn_tilemap.hide()


# Handles the new levels map
func add_level_scene():
	current_level_scene = load("res://Scenes/Screens/Levels/level_" + str(current_level) + ".tscn").instantiate()
	current_level_node.add_child(current_level_scene)
	
	obstacle_tileMap = current_level_scene.find_child("ObstacleMap")
	item_spawn_tilemap = current_level_scene.find_child("SpawnMap")


# Restarts the player for the new map
func restart_player():
	player = player_instance.instantiate()
	player.ObstacleTileMap = obstacle_tileMap
	
	var player_coordinates = current_level_scene.entity_coordinates["player_spawn_coordinates"]
	player.position = coordinates_to_position(player_coordinates)
	
	current_level_node.add_child(player)


# adds all items of a type
func add_item_type(item_type):
	var item_coordinates = current_level_scene.entity_coordinates[item_type + "_coordinates"]
	
	for coordinate in item_coordinates:
		add_item(item_type, coordinate)


# adds individual item
func add_item(item_type, coordinates):
	var item_instance = load("res://Scenes/Items/" + item_type + ".tscn").instantiate()
	item_instance.position = coordinates_to_position(coordinates)
	
	current_level_node.add_child(item_instance)
	
	items_left += 1


# Adds enemies for the new map
func add_enemies():
	var enemy_coordinates = current_level_scene.entity_coordinates["enemy_coordinates"]
	
	for coordinate in enemy_coordinates:
		add_enemy(coordinate)


# Function for adding enemies
func add_enemy(coordinates):
	var cow = cow_instance.instantiate()
	cow.grid_coordinates = coordinates
	cow.position = coordinates_to_position(coordinates)

	cow.obstacle_tileMap = obstacle_tileMap
	cow.player = player
	
	current_level_node.add_child(cow)


###################################
# Helper functions
###################################

func coordinates_to_position(coordinates):
	return coordinates * tile_size + Vector2(tile_size / 2, tile_size / 2)
