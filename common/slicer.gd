extends Node3D


@onready var area3d = $Area3D
@onready var body_store = $"../../../"

var character: CharacterBody3D

var mesh_slicer = MeshSlicer.new()


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	character = get_parent_node_3d().get_parent_node_3d()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:

	#rotate slicer plane
	if Input.is_action_pressed("scroll_up"):
		rotate_z(0.1)
	if Input.is_action_pressed("scroll_down"):
		rotate_z(-0.1)
	if Input.is_action_just_pressed( "left_mouse" ):
		for body in area3d.get_overlapping_bodies().duplicate():
			if not body is RigidBody3D:
				continue
			slice_body( body )

func slice_body( body: RigidBody3D ):
	# Play slice sound
	var sound = body.get_node("AudioStreamPlayer3D")
	if sound:
		sound.pitch_scale = randf_range( .9, 1.08 )
		sound.play()

	# Mesh instance of the body the slicer is going to slice
	var meshinstance: MeshInstance3D = body.get_node( "MeshInstance3D" )

	# empty transform object
	var transform_input = Transform3D.IDENTITY

	# get the coordinates of the slicer relative to the mesh instance we are about to cut.
	transform_input.origin  = meshinstance.to_local( ( global_transform.origin ) )
	transform_input.basis.x = meshinstance.to_local( ( global_transform.basis.x + body.global_position ) )
	transform_input.basis.y = meshinstance.to_local( ( global_transform.basis.y + body.global_position ) )
	transform_input.basis.z = meshinstance.to_local( ( global_transform.basis.z + body.global_position ) )

	print( "global transform of slicer" )
	print( ( global_transform.origin ) )
	print( ( global_transform.basis.x + body.global_position ) )
	print( ( global_transform.basis.y + body.global_position ) )
	print( ( global_transform.basis.z + body.global_position ) )

	print( "transform input origin and basis" )
	print( transform_input.origin )
	print( transform_input.basis )

	var collision = body.get_node( "CollisionShape3D" )

	# Slice the mesh, return a list of meshes(seems to only return two right now)
	var meshes = mesh_slicer.slice_mesh( transform_input, meshinstance.mesh, null )

	print( str( len( meshes ) ) + " meshes" )

	# Assigns the first mesh to the original object we sliced.
	meshinstance.mesh = meshes[0]

	# create the collision shape for the original object based on first mesh
	if len(meshes[0].get_faces()) > 2:
		collision.shape = meshes[0].create_convex_shape()

	# adjust the center of mass on the original object
	body.center_of_mass_mode = body.CENTER_OF_MASS_MODE_CUSTOM
	body.center_of_mass = body.to_local(
		meshinstance.to_global(
			calculate_center_of_mass( meshes[0] )
		)
	)

	# Should in theory allow for creation of as many meshes as a slice needs.
	for meshh in meshes.slice(1):
		# second half of the mesh
		var body2 = body.duplicate()

		body2.freeze = false

		body_store.add_child(body2)
		meshinstance = body2.get_node("MeshInstance3D")
		collision    = body2.get_node("CollisionShape3D")
		meshinstance.mesh = meshh

		#generate collision
		if len(meshh.get_faces()) > 2:
			collision.shape = meshh.create_convex_shape()

		var leaves: Node3D = body.get_node_or_null("leaves")
		if leaves != null:
			leaves.queue_free()

		#get mesh size
		var aabb = meshes[0].get_aabb()
		var aabb2 = meshh.get_aabb()
		#queue_free() if the mesh is too small
		if aabb2.size.length() < 0.3:
			body2.queue_free()
		if aabb.size.length() < 0.3:
			body.queue_free()

		#adjust the rigidbody center of mass
		body2.center_of_mass = body2.to_local(meshinstance.to_global(calculate_center_of_mass(meshh)))

func calculate_center_of_mass( mesh: ArrayMesh ):
	#Not sure how well this work
	var meshVolume = 0
	var temp = Vector3(0,0,0)
	for i in range(float(len(mesh.get_faces()))/3):
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
