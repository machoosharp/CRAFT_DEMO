@tool
extends StaticBody3D

@export var update = false

@export var a_mesh: ArrayMesh

@onready var coll_shape = $CollisionShape3D
@onready var mesh_instance = $MeshInstance3D


var n = FastNoiseLite.new()
var n2 = FastNoiseLite.new()


# Called when the node enters the scene tree for the first time.
func _ready():
	
	a_mesh = ArrayMesh.new()

	var lenx = 30
	var leny = 30

	var vs = []
	var hs = []
	var nm = []
	for z in range(lenx):
		for x in range(leny):
			var y = n.get_noise_2d( x, z ) * 10
			vs.append( Vector3( x, y, z ) )
			hs.append( y )

	var vertices := PackedVector3Array( vs )

	for i in range( len( vs ) ):

		var u: Vector3 = vs[i]
		var row 	   = int(i / leny)
		var col 	   = i % leny

		nm.append( Vector2( int(u.x/2), int((u.z)/2) ) )

	var normals := PackedVector2Array( nm )

	var idx = []

	for i in range( ( len( vs ) - 2 ) * 2 ):
		var r = int(i/(lenx-1))%(lenx-1)
		var l = int(i/((lenx-1)*(leny-1)*2))
		var a = (i%(lenx-1)) + (lenx*r) + (l*(lenx*leny))
		var b = a + lenx + ( int( i / ((lenx-1)*(leny-1)) ) % 2 )
		var c = b + 1 - ( (lenx + 1) * ( int( i / ((lenx-1)*(leny-1)) ) % 2 ) )
		idx.append( c )
		idx.append( b )
		idx.append( a )

	var indices := PackedInt32Array(idx)

	var array = []
	array.resize(Mesh.ARRAY_MAX)
	array[Mesh.ARRAY_VERTEX] = vertices 
	array[Mesh.ARRAY_INDEX]  = indices
	array[Mesh.ARRAY_TEX_UV] = normals
	a_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, array)
	mesh_instance.mesh = a_mesh

	var s: HeightMapShape3D = coll_shape.shape

	s.map_width = lenx
	s.map_depth = leny

	s.map_data  = hs

	coll_shape.shape = s
	
	coll_shape.position = Vector3((lenx/2)-0.5, 0, (leny/2)-0.5)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
