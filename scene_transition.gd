extends Node2D


signal _transition_finished
signal _scene_loaded
var current_scene = null


func _ready():
	var root = get_tree().root
	current_scene = root.get_child(root.get_child_count() - 1)
	print("Current scene: ", current_scene)


func goto_scene(path):
	_animate_transition()
	await _transition_finished
	call_deferred("_deferred_goto_scene", path)


func _deferred_goto_scene(path):
	current_scene.free()
	
	var s = ResourceLoader.load(path)
	
	current_scene = s.instantiate()
	
	print("New scene loaded: ", current_scene)
	_scene_loaded.emit()
	
	get_tree().root.add_child(current_scene)


func _animate_transition():
	print("Starting transition")
	var transition_rect = $CanvasLayer/TransitionRect
	# Reset values
	transition_rect.material["shader_parameter/progress"] = 0.0
	transition_rect.material["shader_parameter/invert"] = false
	transition_rect.visible = true
	
	var tween = create_tween()
	tween.tween_property(
		transition_rect.material,
		"shader_parameter/progress",
		1.0,
		1
	).from(0.0).set_trans(tween.TRANS_SINE)
	
	await tween.finished
	tween.kill()
	
	# Transition finished - load new screen
	_transition_finished.emit()
	await _scene_loaded
	
	# Scene finished loading - invert transition
	transition_rect.material["shader_parameter/invert"] = true
	
	tween = create_tween()
	tween.tween_property(
		transition_rect.material,
		"shader_parameter/progress",
		0.0,
		1
	).from(1.0).set_trans(tween.TRANS_SINE)
	
	await tween.finished
	transition_rect.visible = false
	
	print("Transition finished")
