extends CharacterBody2D


@export var move_speed = 150.0
@export var base_velocity = -300.0
@export var jump_buffer_time = 0.1
@export var coyote_jump_time = 0.1
@export var wall_slide_factor = 0.05
@export var wall_slide_top_speed = 100

@onready var sprite = $AnimatedSprite2D
@onready var jump_buffer_timer = $JumpBufferTimer
@onready var coyote_timer = $CoyoteTimer
@onready var idle_timer = $IdleTimer
@onready var lick_timer = $LickTimer
@onready var action_ray = $ActionRay
@onready var debug_label = $DebugLabel


var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity") * 0.5
var window_height: float = ProjectSettings.get_setting("physics/2d/default_gravity")
var anim = "idle"
var anim_state = anim

signal started_wall_sliding
var wall_sliding = false


func _ready():
	jump_buffer_timer.wait_time = jump_buffer_time
	coyote_timer.wait_time = coyote_jump_time
	idle_timer.timeout.connect(_on_idle_timeout)
	lick_timer.timeout.connect(_on_lick_timeout)
	sprite.animation_changed.connect(_on_animation_changed)


func _physics_process(delta):
	debug_label.text = "x_velocity %d\ny_velocity %d" % [velocity.x, velocity.y]
	#debug_label.text = "wall_sliding %s" % wall_sliding
	var direction = Input.get_axis("left", "right")
	_apply_gravity(delta, direction)
	_handle_jump()
	_handle_move(direction)
	_reset_pos()
	_update_animations(direction)
	var was_on_floor = is_on_floor()
	move_and_slide()
	var just_left_ledge = was_on_floor and not is_on_floor() and velocity.y >= 0
	if just_left_ledge:
		coyote_timer.start()
		jump_buffer_timer.stop()


func _apply_gravity(delta: float, direction: int):
	var action = "right" if direction > 0 else "left"
	if not is_on_floor():
		var gt = gravity * delta
		if is_on_wall() and velocity.y > 0 and Input.is_action_pressed(action):
			if not wall_sliding:
				wall_sliding = true
			# slowdown until top speed is reached
			if velocity.y > wall_slide_top_speed:
				if velocity.y - gt > wall_slide_top_speed:
					velocity.y -= gt
				else:
					velocity.y = wall_slide_top_speed
			# increase until top speed is reached
			elif velocity.y < wall_slide_top_speed:
				velocity.y += gt * wall_slide_factor
		else: # not wall sliding, default gravity applied
			velocity.y += gt
			wall_sliding = false
	else:
		wall_sliding = false

func _handle_jump():
	if is_on_floor() or coyote_timer.time_left > 0.0:
		if Input.is_action_just_pressed("jump") or jump_buffer_timer.time_left > 0.0:
			$Sfx/JumpSfx.play()
			velocity.y = base_velocity
	if not is_on_floor():
		if Input.is_action_just_pressed("jump") and velocity.y > 0:
			jump_buffer_timer.start()
		if Input.is_action_just_released("jump"):
			velocity.y *= 0.5

func _handle_move(direction: int):
	if direction:
		velocity.x = direction * move_speed
	else:
		velocity.x = move_toward(velocity.x, 0, move_speed)

func _reset_pos():
	if position.y > window_height - 32:
		position.x = 6
		position.y = 140

func _update_animations(direction: int):
	if direction:
		anim = "run"
		sprite.flip_h = direction == -1
		action_ray.scale = Vector2(direction, 1)
	else:
		anim = anim_state

	if velocity.y < 0:
		anim = "jump"
	elif velocity.y > 0:
		anim = "fall"

	if wall_sliding:
		anim = "sliding"

	sprite.play(anim)


func _on_idle_timeout():
	#print("[IDLE TIMEOUT] anim_state: %s | anim: %s " % [anim_state, sprite.animation])
	if anim_state == "idle":
		if sprite.animation == "idle":
			anim_state = "lick"
			idle_timer.stop()
			lick_timer.start()


func _on_lick_timeout():
	#print("[LICK TIMEOUT] anim_state: %s | anim: %s " % [anim_state, sprite.animation])
	if anim_state == "lick":
		if sprite.animation == "lick":
			$Sfx/MeowSfx.play()
			anim_state = "idle"
			lick_timer.stop()
			idle_timer.start()


func _on_animation_changed():
	#print("[ANIMATION CHANGED] anim_state: %s | anim: %s " % [anim_state, sprite.animation])
	if sprite.animation == "idle":
		idle_timer.start()
	if sprite.animation != anim_state:
		anim_state = "idle"
		idle_timer.stop()
		lick_timer.stop()
