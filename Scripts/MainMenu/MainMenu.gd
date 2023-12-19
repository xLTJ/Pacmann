extends Node2D

@onready var gloabl_vars = get_node("/root/global_variables")

func _on_play_pressed():
	get_tree().change_scene_to_file("res://Scenes/Screens/main_screen.tscn")

func _input(event):
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_0:
			gloabl_vars.pathfinding_mode = 'dynamic'
			$CanvasLayer/pathfinding_label.text = '0'
		elif event.keycode == KEY_1:
			gloabl_vars.pathfinding_mode = 'shortest_path'
			$CanvasLayer/pathfinding_label.text = '1'
		elif event.keycode == KEY_2:
			gloabl_vars.pathfinding_mode = 'random_cell'
			$CanvasLayer/pathfinding_label.text = '2'
		elif event.keycode == KEY_3:
			gloabl_vars.pathfinding_mode = 'near_player'
			$CanvasLayer/pathfinding_label.text = '3'
