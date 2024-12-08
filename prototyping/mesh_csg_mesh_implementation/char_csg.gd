extends CharacterBody3D

const FRAME_SIZE = 20
const SPEED = 1.0
const JUMP_VELOCITY = 4.5
const sensitivity = 8
const RAMPUP = 1.0

@onready var cutter = $Camera3D/Area3D
@onready var point = $Camera3D/point
@onready var camera = $Camera3D

var _rotation_input: float
var _tilt_input: float
var _mouse_rotation: Vector3
var _player_rotation: Vector3
var _camera_rotation: Vector3


var gravity = ProjectSettings.get_setting("physics/3d/default_gravity") * 5
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
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
			velocity.x = move_toward(velocity.x, (direction.x * SPEED), RAMPUP)
			velocity.z = move_toward(velocity.z, (direction.z * SPEED), RAMPUP)

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

func _unhandled_input(event):

	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		_rotation_input -= event.relative.x / sensitivity
		_tilt_input -= event.relative.y / sensitivity

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
