extends Node3D

@onready var axe = $"."
var mouse_movement: Vector2
@export_category("Weapon Sway")
@export var sway_min: Vector2 = Vector2(-20,-20)
@export var sway_max: Vector2 = Vector2(20,20)
@export_range(0,0.2,0.01) var sway_speed_position: float = 0.07
@export_range(0,0.2,0.01) var sway_speed_rotation: float = 0.1
@export_range(0,0.25,0.01) var sway_amount_position: float = 0.1
@export_range(0,50,0.1) var sway_amount_rotation: float = 10.0

func _input(event):
	if event is InputEventMouseMotion:
		mouse_movement = event.relative

func sway_weapon(delta):
	# Clamp mouse movement
	mouse_movement = mouse_movement.clamp(axe.sway_min, axe.sway_max)

	# Lerp weapon position based on mouse movement
	position.x = lerp(
		position.x, axe.position.x - (
			mouse_movement.x * axe.sway_amount_position
		) * delta, axe.sway_speed_position
	)
	position.y = lerp(
		position.y, axe.position.y - (
			mouse_movement.y * axe.sway_amount_position
		) * delta, axe.sway_speed_position
	)

	# Lerp weapon rotation based on mouse movement
	rotation_degrees.x = lerp(
		rotation_degrees.x, axe.rotation.x + (
			mouse_movement.y * axe.sway_amount_rotation
		) * delta, axe.sway_speed_rotation
	)
	rotation_degrees.y = lerp(
		rotation_degrees.y, axe.rotation_degrees.y + (
			mouse_movement.x * axe.sway_amount_rotation
		) * delta, axe.sway_speed_rotation
	)

func _physics_process(delta: float):
	sway_weapon(delta)
