extends CharacterBody2D

# Movement Constants
const SPEED = 500.0
const JUMP_VELOCITY = -400.0
const ACCELERATION = 2500.0  # How quickly the player accelerates
const DECELERATION = 1500.0  # How quickly the player stops

# Boost Constants
const MAX_BOOST = 100.0  # Maximum boost value
const BOOST_REGEN_RATE = 50.0  # Boost regenerated per second when idle
const TILT_ANGLE = 15.0  # Angle of tilt during boost

# Boost Variables
var boost = MAX_BOOST
var is_boosting = false

# Node References
var boostSprite: AnimatedSprite2D
var boostSprite2: AnimatedSprite2D
var sound_player: AudioStreamPlayer2D
var player1: AnimatedSprite2D
var player: CharacterBody2D

func _ready() -> void:
	# Initialize node references
	boostSprite = get_node("/root/game/PLAYER/player/Booster")
	boostSprite2 = get_node("/root/game/PLAYER/player/Booster2")
	sound_player = get_node("/root/game/PLAYER/player/Flame-thrower-128555")
	player = get_node("/root/game/PLAYER/player")
	player1 = get_node("/root/game/PLAYER/player/player1")
	
	# Connect animation finished signals
	boostSprite.animation_finished.connect(self._on_animation_finished)
	boostSprite2.animation_finished.connect(self._on_animation_finished)
	
	# Initially hide boost sprites
	boostSprite.visible = false
	boostSprite2.visible = false

func _physics_process(delta: float) -> void:
	# Add gravity if not on floor
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get input direction
	var input_direction := Input.get_axis("ui_left", "ui_right")
	
	# Flip sprite based on movement direction
	if input_direction > 0:
		player1.flip_h = false
	elif input_direction < 0:
		player1.flip_h = true

	# Horizontal movement
	if input_direction != 0:
		velocity.x = move_toward(velocity.x, input_direction * SPEED, ACCELERATION * delta)
	else:
		velocity.x = move_toward(velocity.x, 0, DECELERATION * delta)

	# Boost mechanics
	if Input.is_action_just_pressed("ui_up") and boost > 0:
		sound_player.play()
	elif Input.is_action_just_released("ui_up") or boost == 0:
		sound_player.stop()

	if Input.is_action_pressed("ui_up") and boost > 0:
		# Initial boost start
		if is_on_floor():
			velocity.y = JUMP_VELOCITY
		
		if not is_boosting:
			is_boosting = true
			boostSprite.visible = true
			boostSprite2.visible = true
			boostSprite.play("start")
			boostSprite2.play("start")
		
		# Add skew/tilt logic
		if input_direction != 0:
			# Determine tilt angle based on movement direction
			var tilt_angle = TILT_ANGLE * input_direction
			player.rotation = deg_to_rad(tilt_angle)
		else:
			# Reset rotation when not moving
			player.rotation = 0

		# Mid-boost mechanics
		if boostSprite.animation == "mid":
			velocity.y = move_toward(velocity.y, -SPEED, ACCELERATION * delta)
			boost = max(0.0, boost - delta * (MAX_BOOST / 2.5))

	# Stop boosting and play end animation
	elif is_boosting:
		is_boosting = false
		boostSprite.play("end")
		boostSprite2.play("end")
		player.rotation = 0  # Reset rotation

	# Boost regeneration
	if is_boosting == false:
		boost += BOOST_REGEN_RATE * delta
		boost = min(boost, MAX_BOOST)

	# Move the character
	move_and_slide()

func _on_animation_finished():
	if is_boosting and boostSprite.animation == "start":
		boostSprite.play("mid")
		boostSprite2.play("mid")
	elif not is_boosting and boostSprite.animation == "end":
		boostSprite.stop()
		boostSprite2.stop()
		boostSprite.visible = false
		boostSprite2.visible = false

func get_boost_percentage() -> float:
	return (boost / MAX_BOOST) * 100.0
