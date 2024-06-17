extends Node2D

@onready var animated_sprite_2d = $Heart/AnimatedSprite2D


func _input(event):
	if event.is_action_pressed("return_to_main_menu"):
		SceneTransition.goto_scene("res://main_menu.tscn")


func _on_heart_body_entered(body):
	print("entered")
	animated_sprite_2d.play("default")
