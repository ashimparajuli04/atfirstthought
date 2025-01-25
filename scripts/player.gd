extends CharacterBody2D

const SPEED = 500.0
const JUMP_VELOCITY = -400.0
const ACCELERATION = 1500.0  # How quickly the player accelerates
const DECELERATION = 1500.0  # How quickly the player stops
const MAX_BOOST = 100.0  # Maximum boost value
const BOOST_REGEN_RATE = 50.0  # Boost regenerated per second when idle

var boost = MAX_BOOST
var is_boosting = false
var boostSprite: AnimatedSprite2D
var boostSprite2: AnimatedSprite2D
var sound_player: AudioStreamPlayer2D
var player1: AnimatedSprite2D

func _ready() -> void:
	boostSprite = get_node("/root/game/PLAYER/player/Booster")
	boostSprite2 = get_node("/root/game/PLAYER/player/Booster2")
	sound_player = get_node("/root/game/PLAYER/player/Flame-thrower-128555")
	boostSprite.animation_finished.connect(self._on_animation_finished)
	boostSprite2.animation_finished.connect(self._on_animation_finished)
	boostSprite.visible = false
	boostSprite2.visible = false
	player1 = get_node("/root/game/PLAYER/player/player1")

func _physics_process(delta: float) -> void:
	# Add gravity
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction
	var input_direction := Input.get_axis("ui_left", "ui_right")
	if input_direction > 0:
		player1.flip_h = false
	elif input_direction < 0:
		player1.flip_h = true
	# Apply acceleration for horizontal movement
	if input_direction != 0:
		velocity.x = move_toward(velocity.x, input_direction * SPEED, ACCELERATION * delta)
	else:
		# Decelerate to stop when there's no input
		velocity.x = move_toward(velocity.x, 0, DECELERATION * delta)

	
	if Input.is_action_just_pressed("ui_up") and boost>0:
		sound_player.play()
	elif Input.is_action_just_released("ui_up") or boost==0:
		sound_player.stop()
	
	if Input.is_action_pressed("ui_up") and boost > 0:
		if not is_boosting:
			is_boosting = true
			boostSprite.visible = true
			boostSprite2.visible = true
			boostSprite.play("start")
			boostSprite2.play("start")  # Play the start animation once
		elif boostSprite.animation == "mid":
			velocity.y = move_toward(velocity.y, -SPEED, ACCELERATION * delta)
			boost = max(0.0, boost - delta * (MAX_BOOST / 2.0))
	elif is_boosting:
		is_boosting = false
		boostSprite.play("end")
		boostSprite2.play("end")  # Play the end animation when boosting stops

	# Gradually regenerate boost
	if not Input.is_action_pressed("ui_up") and boost < MAX_BOOST and is_on_floor():
		boost += BOOST_REGEN_RATE * delta
		boost = min(boost, MAX_BOOST)

	# Move the character
	move_and_slide()

func _on_animation_finished():
	if is_boosting and boostSprite.animation == "start":
		boostSprite.play("mid")
		boostSprite2.play("mid")  # Transition from start to mid animation
	elif not is_boosting and boostSprite.animation == "end":
		boostSprite.stop()
		boostSprite2.stop()
		boostSprite.visible = false  # Stop the animation after the end is playedlide()
		boostSprite2.visible = false 
		
func get_boost_percentage() -> float:
	return (boost / MAX_BOOST) * 100.0
