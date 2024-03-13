extends Node2D

func _input(event):
	if event.is_action_pressed("return_to_main_menu"):
		SceneTransition.goto_scene("res://main_menu.tscn")
