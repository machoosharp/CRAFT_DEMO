extends Node3D


@export var THROW_FORCE: float = 10
@onready var ray_cast: RayCast3D = $RayCast3D

var held_object: RigidBody3D
var object_previous_parent: Node3D
var held_rotation: Vector3
var cam_rotation: Vector3

@onready var cam = get_parent_node_3d()

func _physics_process( _delta ):
	if Input.is_action_just_pressed("right_mouse"):
		pickup()
	if Input.is_action_just_released("right_mouse"):
		drop()
	if Input.is_action_just_pressed("left_mouse"):
		throw()

	if not held_object:
		return

	held_object.global_position = (
		cam.global_position.direction_to(
			held_object.global_position 
		) + ray_cast.global_position
	)
	
	var cam_rotation_offset = cam.global_rotation - cam_rotation

	held_object.global_rotation = held_rotation
	held_object.global_rotation.y = held_rotation.y + cam_rotation_offset.y

	held_object.linear_velocity = Vector3(0,0,0)
	held_object.angular_velocity = Vector3(0,0,0)

func pickup():

	# Collect reference for held object
	var test_obj = ray_cast.get_collider()
	if not test_obj is RigidBody3D or test_obj.is_freeze_enabled():
		return

	held_object = test_obj

	held_rotation = held_object.global_rotation
	cam_rotation  = cam.global_rotation

func throw():
	if not held_object:
		return

	held_object.apply_central_impulse(
		cam.global_position.direction_to(ray_cast.global_position).normalized() * THROW_FORCE
	)
	
	held_object = null

func drop():

	if not held_object:
		return

	held_object = null
