extends Node2D

# @export var enemy_coordinates = [Vector2(6, 8), Vector2(7, 8)]
# @export var player_spawn_coordinates = Vector2(7, 1)

var entity_coordinates = {}

var tile_size = 32

@onready var spawn_map = $SpawnMap
@onready var onstacle_map = $ObstacleMap


# Called when the node enters the scene tree for the first time.
func _ready():
	get_spawn_coordinates()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func get_spawn_coordinates():
	entity_coordinates["player_spawn_coordinates"] = get_cells_by_id(8)[0]
	entity_coordinates["enemy_coordinates"] = get_cells_by_id(7)
	entity_coordinates["skibid_point_coordinates"] = get_cells_by_id(0)
	entity_coordinates["skibid_ball_coordinates"] = get_cells_by_id(1)


func get_cells_by_id(cell_id):
	var spawn_cells_int = spawn_map.get_used_cells_by_id(0, -1, Vector2i(cell_id, 0))
	var spawn_cells = []
	
	for cell in spawn_cells_int:
		spawn_cells.append(Vector2(cell.x, cell.y))
	
	return spawn_cells


func coordinates_to_position(coordinates):
	return coordinates * tile_size + Vector2(tile_size / 2, tile_size / 2)
