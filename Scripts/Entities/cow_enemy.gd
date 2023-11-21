extends CharacterBody2D

@export var speed = 5
@export var ObstacleTileMap: TileMap

const tile_size = 32
var grid_coordinates = Vector2(0, 0)

func _ready():
	pass


func _physics_process(delta):
	pass


func get_coordinates():
	var cow_coordinates = (position / tile_size)
	cow_coordinates.x -= 0.5
	cow_coordinates.y -= 0.5
	return cow_coordinates
