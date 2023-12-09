extends Node2D

# @export var enemy_coordinates = [Vector2(6, 8), Vector2(7, 8)]
# @export var player_spawn_coordinates = Vector2(7, 1)

var enemy_coordinates = []
var player_spawn_coordinates

@onready var spawn_map = $SpawnMap


# Called when the node enters the scene tree for the first time.
func _ready():
	get_spawn_coordinates()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func get_spawn_coordinates():
	player_spawn_coordinates = get_cells_by_id(8)[0]
	enemy_coordinates = get_cells_by_id(7)

func get_cells_by_id(cell_id):
	var spawn_cells_int = spawn_map.get_used_cells_by_id(0, -1, Vector2i(cell_id, 0))
	var spawn_cells = []
	
	for cell in spawn_cells_int:
		spawn_cells.append(Vector2(cell.x, cell.y))
	
	return spawn_cells
