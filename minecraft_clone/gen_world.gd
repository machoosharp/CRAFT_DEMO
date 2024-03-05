extends Node3D

var n = FastNoiseLite.new()
var n2 = FastNoiseLite.new()

@onready var grass_block = $GRASS_BLOCK
@onready var sand_block  = $SAND_BLOCK
@onready var dirt_block  = $DIRT_BLOCK


# Called when the node enters the scene tree for the first time.
func _ready():
	n.set_seed(randi())
	n2.set_seed(randi())
	for x in range(30):
		for y in range(30):
			var h = n.get_noise_2d(x, y)
			var b = n2.get_noise_2d(x, y)

			print(b)

			var new_grass: Node3D = grass_block.duplicate()
			var new_sand: Node3D  = sand_block.duplicate()
			var tt: Node3D

			if b > 0.1:
				tt = new_sand

			else:
				tt = new_grass

			tt.position = Vector3(x, int(h*100)+100, y)
			self.add_child(tt)

			for i in range((h*100)+100):
				var new_dirt: Node3D  = dirt_block.duplicate()
				new_dirt.position = Vector3(x, i, y)
				self.add_child(new_dirt)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
