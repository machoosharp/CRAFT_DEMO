extends Control


@onready var cam: Camera3D     = $"../Camera3D"
@onready var ltransform: Label = $"VBoxContainer/Transform"
@onready var lx: Label         = $"VBoxContainer/x"
@onready var ly: Label         = $"VBoxContainer/y"
@onready var lz: Label         = $"VBoxContainer/z"
@onready var ldirection: Label = $"VBoxContainer/direction"

var x: float     = 0.0
var y: float     = 0.0
var z: float     = 0.0
var y_rot: float = 0.0
var x_rot: float = 0.0

var trans: Transform3D = Transform3D()

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	cam = get_parent()
	if not cam:
		return

	ltransform.text = (
		str(cam.global_transform)
	)

	lx.text = str(round(cam.global_position.x * 10) / 10)
	ly.text = str(round((cam.global_position.y - 1.7) * 10) / 10)
	lz.text = str(round(cam.global_position.z * 10) / 10)
	ldirection.text = (
		str(round(cam.global_rotation_degrees.x * 10) / 10) + ' | ' +
		str(round(cam.global_rotation_degrees.y * 10) / 10)
	)
