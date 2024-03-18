extends MarginContainer

@onready var start_button = %StartButton


func _ready():
	start_button.grab_focus()


func _on_start_button_pressed():
	SceneTransition.goto_scene("res://level_1.tscn")


func _on_quit_button_pressed():
	get_tree().quit()
