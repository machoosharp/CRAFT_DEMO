extends CharacterBody3D


const SPEED = 8.0
const JUMP_VELOCITY = 13

@onready var pause_menu = $Camera3D/PauseMenu
@onready var player_ui  = $"../PlayerUI/Crosshair"
@onready var camera     = $Camera3D
@onready var slicer     = $Camera3D/Slicer

var mesh_slicer = MeshSlicer.new()

var locked = false
var paused = false
var _rotation_input: float
var _tilt_input: float
var _mouse_rotation: Vector3
var _player_rotation: Vector3
var _camera_rotation: Vector3

@export var sensitivity = 8

@onready var body_store = $"../RigidBodiesStore"
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
			velocity.x = direction.x * SPEED
			velocity.z = direction.z * SPEED

			# Footstep Logic
			if is_on_floor():
				walk_animation.play( 'walking' )

		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
			velocity.z = move_toward(velocity.z, 0, SPEED)
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	if position.y < -100:
		position = Vector3(0, 0, 0)

	move_and_slide()

	if Input.is_action_just_pressed("left_mouse"):
		for body in $Camera3D/Slicer/Area3D.get_overlapping_bodies().duplicate():
			if body is RigidBody3D:


				#The plane transform at the rigidbody local transform
				var meshinstance = body.get_node("MeshInstance3D")
				var Transform = Transform3D.IDENTITY
				Transform.origin = meshinstance.to_local((slicer.global_transform.origin))
				Transform.basis.x = meshinstance.to_local((slicer.global_transform.basis.x+body.global_position))
				Transform.basis.y = meshinstance.to_local((slicer.global_transform.basis.y+body.global_position))
				Transform.basis.z = meshinstance.to_local((slicer.global_transform.basis.z+body.global_position))



				var collision = body.get_node("CollisionShape3D")

				#Slice the mesh
				var meshes = mesh_slicer.slice_mesh(Transform,meshinstance.mesh,null)

				meshinstance.mesh = meshes[0]

				#generate collision
				if len(meshes[0].get_faces()) > 2:
					collision.shape = meshes[0].create_convex_shape()

				#adjust the rigidbody center of mass
				body.center_of_mass_mode = 1
				body.center_of_mass = body.to_local(meshinstance.to_global(calculate_center_of_mass(meshes[0])))

				#second half of the mesh
				var body2 = body.duplicate()
				body_store.add_child(body2)
				meshinstance = body2.get_node("MeshInstance3D")
				collision = body2.get_node("CollisionShape3D")
				meshinstance.mesh = meshes[1]

				#generate collision
				if len(meshes[1].get_faces()) > 2:
					collision.shape = meshes[1].create_convex_shape()

				#get mesh size
				var aabb = meshes[0].get_aabb()
				var aabb2 = meshes[1].get_aabb()
				#queue_free() if the mesh is too small
				if aabb2.size.length() < 0.3:
					body2.queue_free()
				if aabb.size.length() < 0.3:
					body.queue_free()

				#adjust the rigidbody center of mass
				body2.center_of_mass = body2.to_local(meshinstance.to_global(calculate_center_of_mass(meshes[1])))

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

	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		_rotation_input -= event.relative.x / sensitivity
		_tilt_input -= event.relative.y / sensitivity

	if Input.is_action_pressed("wireframe"):
		var vp = get_viewport()
		vp.debug_draw = (vp.debug_draw + 1) % 5

	#rotate slicer plane
	if Input.is_action_pressed("scroll_up"):
		slicer.rotate_z(0.1)
	if Input.is_action_pressed("scroll_down"):
		slicer.rotate_z(-0.1)

func calculate_center_of_mass(mesh:ArrayMesh):
	#Not sure how well this work
	var meshVolume = 0
	var temp = Vector3(0,0,0)
	for i in range(len(mesh.get_faces())/3):
		var v1 = mesh.get_faces()[i]
		var v2 = mesh.get_faces()[i+1]
		var v3 = mesh.get_faces()[i+2]
		var center = (v1 + v2 + v3) / 3
		var volume = (Geometry3D.get_closest_point_to_segment_uncapped(v3,v1,v2).distance_to(v3)*v1.distance_to(v2))/2
		meshVolume += volume
		temp += center * volume

	if meshVolume == 0:
		return Vector3.ZERO
	return temp / meshVolume

func _play_walk_sound():
	grass_footstep.pitch_scale = randf_range( .9, 1.08 )
	grass_footstep.play()

func pause_game():
	if Input.mouse_mode != Input.MOUSE_MODE_VISIBLE:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	elif Input.mouse_mode == Input.MOUSE_MODE_VISIBLE:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	if paused:
		pause_menu.hide()
		player_ui.show()
	else:
		pause_menu.show()
		player_ui.hide()

	paused = !paused
