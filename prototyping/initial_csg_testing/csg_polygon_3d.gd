extends CSGMesh3D


var res_path = "res://prototyping/initial_csg_testing/obj/test.tres"
# To allow for percistant mesh. in the CSGMesh, load the mesh from the res_path above.

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_update_shape()
	var mesh = get_meshes()[1]
	ResourceSaver.save(mesh, res_path)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed( "left_mouse" ):
		
		# Loads the saved mesh reference
		var new_mesh = ResourceLoader.load(res_path, "Mesh")
		# Sets our mesh to the saved mesh
		self.mesh = new_mesh
		# Updates the mesh
		_update_shape()
		# Gets updated mesh
		var mesh2 = get_meshes()[1]
		# Overrides the reference mesh
		ResourceSaver.save(mesh2, res_path)
		# Sets current mesh to updated mesh
		self.mesh = mesh2
		
		# unsure how many of these steps are redundant or not. but setting
		# the resource to be the same as res_path will allow for persistance.
		# If the local mesh and the res_path are different, relaunching the 
		# game will reset the mesh back to normal. Unsure how to make this
		# a setting in code yet, should have something to do with Resource.
