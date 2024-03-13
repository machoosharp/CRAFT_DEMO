extends DirectionalLight3D

@export var x: float
@export var y: float

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):

	var day_speed = 200.0

	var ticks = Time.get_ticks_msec() * 0.1

	var t = ( int( ticks ) ) / day_speed

	rotation.x = deg_to_rad(t-180)


