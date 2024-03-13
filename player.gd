extends CharacterBody2D


const SPEED = 150.0
const JUMP_VELOCITY = -400.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var anim = "lick"
@onready var sprite = $AnimatedSprite2D
@onready var idle_timer = $IdleTimer
@onready var lick_timer = $LickTimer

func _ready():
	sprite.connect("animation_changed", _sprite_anim_changed)
	idle_timer.connect("timeout", _idle_timeout)
	lick_timer.connect("timeout", _lick_timeout)

func _sprite_anim_changed():
	print(sprite.animation)

func _idle_timeout():
	print("idle timeout. anim: ", sprite.animation)
func _lick_timeout():
	print("lick timeout. anim: ", sprite.animation)
	
func _process(delta):
	if idle_timer.is_stopped() and anim == "idle":
		lick_timer.start()
	if lick_timer.is_stopped() and anim == "lick":
		idle_timer.start()

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction = Input.get_axis("ui_left", "ui_right")
	if direction:
		anim = "run"
		velocity.x = direction * SPEED
		if direction == -1:
			sprite.flip_h = true
		else:
			sprite.flip_h = false
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	if velocity.y < 0:
		anim = "jump"
	elif velocity.y > 0:
		anim = "fall"
#
	if velocity.x == 0 and velocity.y == 0:
		if idle_timer.time_left > 0:
			anim = "idle"
		elif lick_timer.time_left > 0:
			anim = "lick"

	sprite.play(anim)
	move_and_slide()
