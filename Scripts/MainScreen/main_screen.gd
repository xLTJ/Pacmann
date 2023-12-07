extends Node2D
@export var obstacle_tileMap: TileMap
@export var cow_instance: PackedScene
@export var enemy_coordinates = [Vector2(8, 8), Vector2(9, 8)]
@onready var tile_size = 32


# Called when the node enters the scene tree for the first time.
func _ready():
	for cow_coordinate in enemy_coordinates:
		add_enemy(cow_coordinate)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func add_enemy(coordinates):
	var cow = cow_instance.instantiate()
	cow.grid_coordinates = coordinates
	cow.position = coordinates * tile_size + Vector2(tile_size / 2, tile_size / 2)

	cow.obstacle_tileMap = obstacle_tileMap
	
	add_child(cow)
