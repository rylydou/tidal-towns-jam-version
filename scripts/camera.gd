extends Node3D

@export var move_speed = 10.0
@export var turn_speed = 1.5

@export var position_easing = 10.0
@export var rotation_easing = 10.0
@export var zoom_easing = 10.0

@onready var camera: Camera3D = get_child(0)

@onready var target_position := position
@onready var target_rotation := rotation.y

@onready var target_zoom := camera.position.z

func _process(delta: float) -> void:
	var move_input := Input.get_vector('left', 'right', 'backward', 'forward')
	var right := global_transform.basis.x
	var forward := -global_transform.basis.z
	forward = forward.slide(Vector3.UP).normalized()
	var move := forward*move_input.y + right*move_input.x
	
	target_position += Vector3(move.x, 0, move.z)*move_speed*delta
	target_position.y = position.y
	
	position = lerp(target_position, position, exp(delta * -position_easing))
	
	target_rotation += Input.get_axis('turn_left', 'turn_right')*turn_speed*delta
	
	global_rotation.y = lerp_angle(target_rotation, global_rotation.y, exp(delta * -rotation_easing))

	if Input.is_action_just_pressed('zoom_in'):
		target_zoom -= 1
	elif Input.is_action_just_pressed('zoom_out'):
		target_zoom += 1
	else:
		target_zoom += Input.get_axis('zoom_in', 'zoom_out')
	
	target_zoom = clamp(target_zoom, 25, 35)
	camera.position.z = lerp(target_zoom, camera.position.z, exp(delta * -zoom_easing))
