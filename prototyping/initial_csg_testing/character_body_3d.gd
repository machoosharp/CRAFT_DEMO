extends CharacterBody3D

const FRAME_SIZE = 20
const SPEED = 1.0
const JUMP_VELOCITY = 4.5
const sensitivity = 200

@onready var box: CSGSphere3D = $"../CSGBox3D"
@onready var ball = $MeshInstance3D
@onready var point = $point


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _physics_process(delta: float) -> void:
	# Add the gravity.
	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("left", "right", "forward", "backward")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()


	ball.global_position = round( point.global_position * FRAME_SIZE)/FRAME_SIZE
	
	box.global_position = round( point.global_position * FRAME_SIZE )/FRAME_SIZE
	#box.rotation.x += deg_to_rad(90)

func _unhandled_input(event):
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		rotation.x -= event.relative.y / sensitivity
		rotation.y -= event.relative.x / sensitivity
