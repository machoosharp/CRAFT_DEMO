extends CharacterBody3D


const SPEED = 8.0
const JUMP_VELOCITY = 13

var locked = false
var _rotation_input: float
var _tilt_input: float
var _mouse_rotation: Vector3
var _player_rotation: Vector3
var _camera_rotation: Vector3

@export var sensitivity = 8

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity") * 5

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

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
			velocity.x = direction.x * SPEED
			velocity.z = direction.z * SPEED

		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
			velocity.z = move_toward(velocity.z, 0, SPEED)
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	if position.y < -100:
		position = Vector3(0, 0, 0)

	move_and_slide()

func _update_camera(delta):
	_mouse_rotation.x += _tilt_input * delta
	_mouse_rotation.y += _rotation_input * delta
	_mouse_rotation.x = clamp(_mouse_rotation.x, deg_to_rad(-85), deg_to_rad(85))

	_player_rotation = Vector3(0.0, _mouse_rotation.y, 0.0)
	_camera_rotation = Vector3(_mouse_rotation.x, 0.0, 0.0)

	$Camera3D.transform.basis = Basis.from_euler(_camera_rotation)
	$Camera3D.rotation.z = 0.0

	global_transform.basis = Basis.from_euler(_player_rotation)

	_rotation_input = 0.0
	_tilt_input = 0.0

func _unhandled_input(event):

	#if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		#rotation.y -= event.relative.x / sensitivity
		#$Camera3D.rotation.x -= event.relative.y / sensitivity
		#$Camera3D.rotation.x = clamp($Camera3D.rotation.x, deg_to_rad(-85), deg_to_rad(85))

	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		_rotation_input -= event.relative.x / sensitivity
		_tilt_input -= event.relative.y / sensitivity


	elif event is InputEventKey:
		if event.keycode == KEY_ESCAPE:
			if event.pressed and not locked:
				locked = true
				if Input.mouse_mode != Input.MOUSE_MODE_VISIBLE:
					Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

				elif Input.mouse_mode == Input.MOUSE_MODE_VISIBLE:
					Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

			elif not event.pressed:
				locked = false

