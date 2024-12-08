extends Area3D

@onready var meshi_a = $MeshInstance3D

func _on_body_entered(body: Node3D) -> void:
	
	# operation can only be done on physics bodies with child mesh child collision shape
	if not body is RigidBody3D and not body is StaticBody3D:
		return

	# get mesh of body we entered
	var mesh_inst_of_body: MeshInstance3D = body.get_node_or_null("MeshInstance3D")
	if not mesh_inst_of_body:
		return

	# create CSGMesh for body we entered, give it the mesh of the body we entered
	var csg_mesh_of_body = CSGMesh3D.new()
	csg_mesh_of_body.mesh = mesh_inst_of_body.mesh
	
	# add node to scene, could probably be anywhere.
	# for conveinience we just put it in the colliding body 
	body.add_child(csg_mesh_of_body)

	# create a CSGMesh for our own body, the cutting object
	var csg_cutter = CSGMesh3D.new()
	# Set operation to subtraction, this is what performs the cut
	csg_cutter.operation = CSGShape3D.OPERATION_SUBTRACTION
	# Add our own mesh to the csg mesh
	csg_cutter.mesh = meshi_a.mesh

	# Add cutter as child to other CSG, acting CSG must be child of a CSG to act upon it
	csg_mesh_of_body.add_child(csg_cutter)

	# position the cutter in the location of the cutting device
	csg_cutter.global_position = global_position
	csg_cutter.global_rotation = global_rotation

	# This calls the internal function which performs the CSG Operationg, the cut
	csg_mesh_of_body._update_shape()

	# Get the newly cut mesh from the CSG, apply it to the recieving body
	mesh_inst_of_body.mesh = csg_mesh_of_body.get_meshes()[1]
	
	# Delete the CSG Nodes as they are laggy and take up space.
	csg_cutter.queue_free()
	csg_mesh_of_body.queue_free()
