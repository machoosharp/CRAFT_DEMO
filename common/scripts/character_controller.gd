extends CharacterBody3D


const SPEED = 8.0
const RAMPUP = 1.0
const JUMP_VELOCITY = 13

@onready var camera     = $Camera3D
@onready var pause_menu = $Camera3D/PauseMenu
@onready var player_ui  = $"../PlayerUI/Crosshair"

var locked = false
var paused = false
var _rotation_input: float
var _tilt_input: float
var _mouse_rotation: Vector3
var _player_rotation: Vector3
var _camera_rotation: Vector3

@export var sensitivity = 8

@onready var grass_footstep = $Audios/GrassFootstep
@onready var walk_animation = $AnimationPlayers/WalkAnimation

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity") * 5

func _init():
	RenderingServer.set_debug_generate_wireframes(true)

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _process(_delta):
	if Input.is_action_just_pressed('Pause'):
		pause_game()

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	_update_camera(delta)

	# Handle jump.
	if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		if Input.is_action_just_pressed("up") and is_on_floor():
			velocity.y = JUMP_VELOCITY

		# Get the input direction and handle the movement/deceleration.
		# As good practice, you should replace UI actions with custom gameplay actions.
		var input_dir = Input.get_vector("left", "right", "forward", "backward")
		var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

		if direction:
			velocity.x = move_toward(velocity.x, (direction.x * SPEED), RAMPUP)
			velocity.z = move_toward(velocity.z, (direction.z * SPEED), RAMPUP)

			# Footstep Logic
			if is_on_floor():
				walk_animation.play( 'walking' )

		else:
			velocity.x = move_toward(velocity.x, 0, RAMPUP)
			velocity.z = move_toward(velocity.z, 0, RAMPUP)
	else:
		velocity.x = move_toward(velocity.x, 0, RAMPUP)
		velocity.z = move_toward(velocity.z, 0, RAMPUP)

	if position.y < -100:
		position = Vector3(0, 1, 0)

	move_and_slide()

	# push rigidbody
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		for j in collision.get_collision_count():
			var obj = collision.get_collider(j)
			if obj is RigidBody3D:
				obj.apply_central_impulse(position.direction_to(obj.position)/2)

func _update_camera( delta ):
	_mouse_rotation.x += _tilt_input * delta
	_mouse_rotation.y += _rotation_input * delta
	_mouse_rotation.x = clamp(_mouse_rotation.x, deg_to_rad(-85), deg_to_rad(85))

	_player_rotation = Vector3( 0.0, _mouse_rotation.y, 0.0)
	_camera_rotation = Vector3( _mouse_rotation.x, 0.0, 0.0)

	camera.transform.basis = Basis.from_euler(_camera_rotation)
	camera.rotation.z = 0.0

	global_transform.basis = Basis.from_euler(_player_rotation)

	_rotation_input = 0.0
	_tilt_input = 0.0

func _unhandled_input(event):

	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		_rotation_input -= event.relative.x / sensitivity
		_tilt_input -= event.relative.y / sensitivity

	if Input.is_action_pressed("wireframe"):
		var vp = get_viewport()
		vp.debug_draw = (vp.debug_draw + 1) % 5

func _play_walk_sound():
	grass_footstep.pitch_scale = randf_range( .9, 1.08 )
	grass_footstep.play()

func pause_game():
	if Input.mouse_mode != Input.MOUSE_MODE_VISIBLE:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	elif Input.mouse_mode == Input.MOUSE_MODE_VISIBLE:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	if player_ui is Control:

		if paused:
			pause_menu.hide()
			player_ui.show()

		else:
			pause_menu.show()
			player_ui.hide()

	paused = !paused
