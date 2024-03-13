extends CharacterBody2D

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")
var window_height: float = ProjectSettings.get_setting("physics/2d/default_gravity")
@export var jump_buffer_time = 0.1
@export var move_speed = 150.0
@export var base_velocity = -300.0

var anim = "idle"
@onready var sprite = $AnimatedSprite2D
@onready var idle_timer = $IdleTimer
@onready var lick_timer = $LickTimer

var _jump_buffer_timer: float = 0


func _ready():
	_jump_buffer_timer = jump_buffer_time


func _input(event):
	if Input.is_action_just_pressed("jump"):
		_jump_buffer_timer = jump_buffer_time


func _process(delta):
	_jump_buffer_timer -= delta


func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta

	# Handle jump.
	if is_on_floor():
		if Input.is_action_just_pressed("jump") or _jump_buffer_timer > 0:
			velocity.y = base_velocity
	if Input.is_action_just_released("jump"):
		velocity.y *= 0.5

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction = Input.get_axis("left", "right")
	if direction:
		anim = "run"
		velocity.x = direction * move_speed
		if direction == -1:
			sprite.flip_h = true
		else:
			sprite.flip_h = false
	else:
		velocity.x = move_toward(velocity.x, 0, move_speed)
		
	
	if position.y > window_height - 32:
		position.x = 6
		position.y = 140

	if velocity.y < 0:
		anim = "jump"
	elif velocity.y > 0:
		anim = "fall"
#
	if velocity.x == 0 and velocity.y == 0:
		anim = "idle"

	sprite.play(anim)
	move_and_slide()
