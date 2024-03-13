extends CharacterBody2D

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")
@export var jump_buffer_time = 0.1
@export var move_speed = 150.0
@export var base_velocity = -300.0

var anim = "idle"
@onready var sprite = $AnimatedSprite2D
@onready var idle_timer = $IdleTimer
@onready var lick_timer = $LickTimer

var _jump_buffer_timer: float = 0
#func _process(_delta):
	#if idle_timer.is_stopped() and anim == "idle":
		#lick_timer.start()
	#if lick_timer.is_stopped() and anim == "lick":
		#idle_timer.start()


func _input(event):
	if Input.is_action_just_pressed("ui_accept"):
		_jump_buffer_timer = jump_buffer_time


func _process(delta):
	_jump_buffer_timer -= delta


func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta

	# Handle jump.
	if is_on_floor():
		if Input.is_action_just_pressed("ui_accept") or _jump_buffer_timer > 0:
			velocity.y = base_velocity

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction = Input.get_axis("ui_left", "ui_right")
	if direction:
		anim = "run"
		velocity.x = direction * move_speed
		if direction == -1:
			sprite.flip_h = true
		else:
			sprite.flip_h = false
	else:
		velocity.x = move_toward(velocity.x, 0, move_speed)

	if velocity.y < 0:
		anim = "jump"
	elif velocity.y > 0:
		anim = "fall"
#
	if velocity.x == 0 and velocity.y == 0:
		anim = "idle"

	sprite.play(anim)
	move_and_slide()
