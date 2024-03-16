extends Node3D

@onready var ray_cast: RayCast3D = $RayCast3D
var current_object: RigidBody3D
var object_previous_parent: Node3D

func pickup():
	# if already holding an object, drop it
	if current_object:
		return drop()
	var selected_object = ray_cast.get_collider()
	if not selected_object is RigidBody3D or selected_object.is_freeze_enabled():
		return
	# Collect reference for held object
	current_object = ray_cast.get_collider()
	object_previous_parent = current_object.get_parent()
	current_object.reparent(self)
	current_object.freeze = true

func drop():
	current_object.reparent(object_previous_parent)
	current_object.freeze = false
	
	current_object = null
