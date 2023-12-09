extends Node2D
@export var cow_instance: PackedScene
@export var player_instance: PackedScene
@onready var tile_size = 32

@onready var current_level = 0

var obstacle_tileMap: TileMap
var item_spawn_tilemap: TileMap

var current_level_scene



# Called when the node enters the scene tree for the first time.
func _ready():
	next_level()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

# Transitions to next level
func next_level():
	if current_level_scene:
		current_level_scene.queue_free()
	
	add_next_scene()
	restart_player()
	add_enemies()

# Handles the new levels map
func add_next_scene():
	current_level += 1
	current_level_scene = load("res://Scenes/Screens/Levels/level_" + str(current_level) + ".tscn").instantiate()
	add_child(current_level_scene)
	
	obstacle_tileMap = current_level_scene.find_child("ObstacleMap")
	item_spawn_tilemap = current_level_scene.find_child("SpawnMap")

# Restarts the player for the new map
func restart_player():
	var player = player_instance.instantiate()
	player.ObstacleTileMap = obstacle_tileMap
	
	var player_coordinates = current_level_scene.player_spawn_coordinates
	player.position = player_coordinates * tile_size + Vector2(tile_size / 2, tile_size / 2)
	
	add_child(player)

# Adds enemies for the new map
func add_enemies():
	var enemies_coordinates = current_level_scene.enemy_coordinates
	# item_spawn_tilemap.cell
	
	for cow_coordinate in enemies_coordinates:
		add_enemy(cow_coordinate)

# Function for adding enemies
func add_enemy(coordinates):
	var cow = cow_instance.instantiate()
	cow.grid_coordinates = coordinates
	cow.position = coordinates * tile_size + Vector2(tile_size / 2, tile_size / 2)

	cow.obstacle_tileMap = obstacle_tileMap
	
	add_child(cow)

