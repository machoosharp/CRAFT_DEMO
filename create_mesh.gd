@tool
extends MeshInstance3D

@export var update = false

@export var a_mesh: ArrayMesh

# Called when the node enters the scene tree for the first time.
func _ready():
	gen_mesh()



func gen_mesh():

	var a_mesh = ArrayMesh.new()

	var vertices := PackedVector3Array([
		Vector3(-0.5,-0.5,-0.5),  # 0
		Vector3( 0.5,-0.5,-0.5),  # 1
		Vector3( 0.5, 0.5,-0.5),  # 2
		Vector3(-0.5, 0.5,-0.5),  # 3
		Vector3(-0.5, 0.5, 0.5),  # 4
		Vector3( 0.5, 0.5, 0.5),  # 5
		Vector3( 0.5,-0.5, 0.5),  # 6
		Vector3(-0.5,-0.5, 0.5),  # 7
		Vector3( 0  , 0.5, 0  ),  # 8
		Vector3( 0  ,-0.5, 0  ),  # 9
		Vector3(-0.5,-0.5,-0.5),  # 10
		Vector3(-0.5, 0.5,-0.5),  # 11
	])

	var uvs = PackedVector2Array([
		Vector2(0,0), 
		Vector2(0,1),
		Vector2(1,1),
		Vector2(1,0),
		Vector2(0,0),
		Vector2(1,0),
		Vector2(1,1),
		Vector2(0,1),
		Vector2(0,1),
		Vector2(0,1),
		Vector2(0,1),
		Vector2(0,1),
	])

	var normals = PackedVector3Array([
		Vector3( 0, 0, 0 ),  # 0
		Vector3( 1, 0, 0 ),  # 1
		Vector3( 1, 1, 0 ),  # 2
		Vector3( 0, 1, 0 ),  # 3
		Vector3( 0, 1, 1 ),  # 4
		Vector3( 1, 1, 1 ),  # 5
		Vector3( 1, 0, 1 ),  # 6
		Vector3( 0, 0, 1 ),  # 7
		Vector3( 0, 0, 1 ),  # 7
		Vector3( 0, 0, 1 ),  # 7
		Vector3( 0, 0, 1 ),  # 7
		Vector3( 0, 0, 1 ),  # 7
	])

	var colors = PackedColorArray([
		Color(0,  90, 200),
		Color(100, 0, 100),
		Color(0,  90, 200),
		Color(100, 0, 100),
		Color(0,  90, 200),
		Color(100, 0, 100),
		Color(0,  90, 200),
		Color(100, 0, 100),
		Color(100, 0, 100),
		Color(100, 0, 100),
		Color(100, 0, 100),
		Color(100, 0, 100)
	])

	var indices := PackedInt32Array([
		# Front
		0, 1, 2,
		0, 2, 3,
		# Top
		3, 2, 4,
		4, 2, 5,
		# Back
		4, 5, 6,
		4, 6, 7,
		# Right
		7, 10, 11,
		7, 11, 4,
		# Bot
		7, 1, 0,
		7, 6, 1,
		# Left
		1, 6, 5,
		1, 5, 2,
		
		0, 8, 3,
		0, 9, 8,
		
		10, 11, 8,
		10, 8, 9
	])

	var array = []
	array.resize(Mesh.ARRAY_MAX)
	array[Mesh.ARRAY_VERTEX] = vertices 
	array[Mesh.ARRAY_INDEX]  = indices
	array[Mesh.ARRAY_TEX_UV] = uvs
	array[Mesh.ARRAY_COLOR]  = colors
	array[Mesh.ARRAY_NORMAL] = normals
	a_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, array)
	mesh = a_mesh
	
	print(mesh.get_surface_count())


func gen_mesh2():
	a_mesh = ArrayMesh.new()

	var lenx = 4
	var leny = 4
	var lenz = 2
	

	var vs = []
	for x in range(4):
		for y in range(4):
			for z in range(4):
				vs.append(Vector3( x, y, z ))

	var vertices := PackedVector3Array(vs)

	var idx = []

	for i in range((len(vs))):
		var r = int(i/(lenx-1))%(lenx-1)
		var l = int(i/((lenx-1)*(leny-1)*2))
		var a = (i%(lenx-1)) + (lenx*r) + (l*(lenx*leny))
		var b = a + lenx + ( int( i / ((lenx-1)*(leny-1)) ) % 2 )
		var c = b + 1 - ( (lenx + 1) * ( int( i / ((lenx-1)*(leny-1)) ) % 2 ) )
		idx.append( a )
		idx.append( b )
		idx.append( c )

	var indices := PackedInt32Array(idx)

	var array = []
	array.resize(Mesh.ARRAY_MAX)
	array[Mesh.ARRAY_VERTEX] = vertices 
	array[Mesh.ARRAY_INDEX]  = indices
	a_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, array)
	mesh = a_mesh

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if update:
		gen_mesh()
		update = false
