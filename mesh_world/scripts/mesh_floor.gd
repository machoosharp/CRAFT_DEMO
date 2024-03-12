#@tool
extends StaticBody3D

@export var update = false

@export var a_mesh: ArrayMesh

@onready var coll_shape = $CollisionShape3D
@onready var mesh_instance = $MeshInstance3D
@onready var tree = $"../logs/LOG"
@onready var logs = $"../logs"


var n1 = FastNoiseLite.new()
var n2 = FastNoiseLite.new()
var n3 = FastNoiseLite.new()
var n4 = FastNoiseLite.new()


# Called when the node enters the scene tree for the first time.
func _ready():

	var surface_tool := SurfaceTool.new()
	
	n1.set_seed(randi())
	n2.set_seed(randi())
	n3.set_seed(randi())
	n4.set_seed(randi())
	
	a_mesh = ArrayMesh.new()

	var lenx = 300
	var leny = 300

	var vs = []
	var hs = []
	var uv = []
	var nms = []
	var done_tree = 0
	for z in range(lenx):
		for x in range(leny):
			var y = n1.get_noise_2d( x, z )
			var t = n2.get_noise_2d( x, z )
			var b = n3.get_noise_2d( x, z )
			var h = n4.get_noise_2d( x, z )

			y = (y+h) * 10

			vs.append(  Vector3( x, y, z ) )
			hs.append(  y )
			uv.append(  Vector2( x%2, z%2 ) )

			if t > 0.3:
				if done_tree == 0:
					var new_tree = tree.duplicate()
					new_tree.position = Vector3( x, y+4, z)
					logs.add_child(new_tree)
					done_tree += 1
				else:
					if done_tree < 50:
						done_tree += 1
					else:
						done_tree = 0

	for i in range( len( vs ) ):

		var _cur   : Vector3 = vs[ i ]
		var _above : Vector3 = vs[ (i + leny) % len(vs) ]
		var _right : Vector3 = vs[ (i + 1) % len(vs) ]

		var vx = _cur - _above

		var vz = _cur - _right

		var vy = vx.cross( vz )

		nms.append( vy )

	var vertices := PackedVector3Array( vs )
	var uvs := PackedVector2Array( uv )
	var normals := PackedVector3Array( nms )

	var idx = []

	for i in range( ( len( vs ) - 2 ) * 2 ):
		var r = int(float(i)/(lenx-1))%(lenx-1)
		var l = int(float(i)/((lenx-1)*(leny-1)*2))
		var a = (i%(lenx-1)) + (lenx*r) + (l*(lenx*leny))
		var b = a + lenx + ( int( float(i) / ((lenx-1)*(leny-1)) ) % 2 )
		var c = b + 1 - ( (lenx + 1) * ( int( float(i) / ((lenx-1)*(leny-1)) ) % 2 ) )
		idx.append( c )
		idx.append( b )
		idx.append( a )

	var indices := PackedInt32Array(idx)

	var array = []
	array.resize(Mesh.ARRAY_MAX)
	array[Mesh.ARRAY_VERTEX] = vertices 
	array[Mesh.ARRAY_INDEX]  = indices
	array[Mesh.ARRAY_TEX_UV] = uvs
	array[Mesh.ARRAY_NORMAL] = normals
	a_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, array)
	mesh_instance.mesh = a_mesh

	# for num "i" each surface in the Mesh
	for i in range( a_mesh.get_surface_count() ):

		# Creates a vertex array from an existing Mesh.
		surface_tool.create_from( a_mesh, i )

	var hmap = HeightMapShape3D.new()
	
	hmap.map_width = lenx
	hmap.map_depth = leny
	
	hmap.map_data  = hs

	coll_shape.shape = hmap
	
	coll_shape.position = Vector3((float(lenx)/2)-0.5, 0, (float(leny)/2)-0.5)

