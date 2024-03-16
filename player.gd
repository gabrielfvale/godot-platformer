extends CharacterBody2D


@export var jump_buffer_time = 0.1
@export var move_speed = 150.0
@export var base_velocity = -300.0

@onready var sprite = $AnimatedSprite2D
@onready var jump_buffer_timer = $JumpBufferTimer
@onready var idle_timer = $IdleTimer
@onready var lick_timer = $LickTimer

var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")
var window_height: float = ProjectSettings.get_setting("physics/2d/default_gravity")
var anim = "idle"
var anim_state = anim


func _ready():
	jump_buffer_timer.wait_time = jump_buffer_time
	idle_timer.timeout.connect(_on_idle_timeout)
	lick_timer.timeout.connect(_on_lick_timeout)
	sprite.animation_changed.connect(_on_animation_changed)


func _input(event):
	if Input.is_action_just_pressed("jump"):
		jump_buffer_timer.start()


func _physics_process(delta):
	var direction = Input.get_axis("left", "right")
	_apply_gravity(delta)
	_handle_jump()
	_handle_move(direction)
	_reset_pos()
	_update_animations(direction)
	move_and_slide()

func _apply_gravity(delta: float):
	if not is_on_floor():
		velocity.y += gravity * delta

func _handle_jump():
	if is_on_floor():
		if Input.is_action_just_pressed("jump") or jump_buffer_timer.time_left > 0.0:
			$Sfx/JumpSfx.play()
			velocity.y = base_velocity
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
	else:
		anim = anim_state

	if velocity.y < 0:
		anim = "jump"
	elif velocity.y > 0:
		anim = "fall"
	
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
