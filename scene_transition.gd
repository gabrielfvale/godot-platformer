extends Node


signal _viewport_set
signal _transition_finished
signal _scene_loaded
var current_scene = null
var next_path = null


@export var invert_shader = true
@export var diamond_pixel_size = 3.5

@onready var texture_rect = $CanvasLayer/TextureRect

func _ready():
	texture_rect.visible = false
	var root = get_tree().root
	current_scene = root.get_child(root.get_child_count() - 1)
	print("Current scene: ", current_scene)
	_viewport_set.connect(_on_viewport_set)
	_scene_loaded.connect(_animate_transition)


func _set_viewport():
	#print("Setting viewport")
	await RenderingServer.frame_post_draw
	var texture = get_viewport().get_texture()
	#var imgtex = ImageTexture.create_from_image(get_viewport().get_texture().get_image())
	texture_rect.texture = ImageTexture.create_from_image(texture.get_image())
	texture_rect.visible = true
	print("Viewport set")
	_viewport_set.emit()


func _on_viewport_set():
	var s = ResourceLoader.load(next_path)
	
	var new_scene = s.instantiate()
	
	print("New scene loaded: ", new_scene)
	
	get_tree().root.add_child(new_scene)
	current_scene.queue_free()
	current_scene = new_scene
	_scene_loaded.emit()


func goto_scene(path):
	next_path = path
	_set_viewport()

#func _deferred_goto_scene(path):
	#print("Loading new scene")
	#current_scene.free()
	#
	#var s = ResourceLoader.load(path)
	#
	#current_scene = s.instantiate()
	#
	#print("New scene loaded: ", current_scene)
	#_scene_loaded.emit()
	#
	#get_tree().root.add_child(current_scene)
#


func _animate_transition():
	#print("Starting transition")
	texture_rect.material["shader_parameter/progress"] = 1.0
	texture_rect.material["shader_parameter/invert"] = invert_shader
	texture_rect.material["shader_parameter/diamondPixelSize"] = diamond_pixel_size

	var tween = create_tween()
	tween.tween_property(
		texture_rect.material,
		"shader_parameter/progress",
		0.0,
		1
	).from(1.0).set_trans(tween.TRANS_SINE)

	await tween.finished
	texture_rect.visible = false
	#print("Transition finished")
