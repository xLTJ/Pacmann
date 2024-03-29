extends Node2D

# @export var enemy_coordinates = [Vector2(6, 8), Vector2(7, 8)]
# @export var player_spawn_coordinates = Vector2(7, 1)

@onready var spawn_map = $SpawnMap
@onready var onstacle_map = $ObstacleMap

var entity_coordinates = {}

var entities_by_id = {
	'player_spawn_coordinates': 8,
	'enemy_coordinates': 7,
	'skibid_point_coordinates': 0,
	'skibid_ball_coordinates': 1,
	'speed_powerup_coordinates': 2
}

var tile_size = 32



# Called when the node enters the scene tree for the first time.
func _ready():
	get_spawn_coordinates()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


# Gets the spawn coordinates for all the different things that needs to be spawned. This information is gathered from the "spawn_map" tilemap.
func get_spawn_coordinates():
	for entity_type in entities_by_id.keys():
		entity_coordinates[entity_type] = get_cells_by_id(entities_by_id[entity_type])


# Gets all cells of a specific id in the "spawn_map" tilemap.
func get_cells_by_id(cell_id):
	var spawn_cells_int = spawn_map.get_used_cells_by_id(0, -1, Vector2i(cell_id, 0))
	var spawn_cells = []
	
	for cell in spawn_cells_int:
		spawn_cells.append(Vector2(cell.x, cell.y))
	
	return spawn_cells
