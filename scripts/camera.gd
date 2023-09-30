extends Node3D

@export var move_speed = 10.0

@export var camera: Camera3D

func _process(delta: float) -> void:
	var move_input := Input.get_vector('left', 'right', 'backward', 'forward')
	var right := global_transform.basis.x
	var forward := -global_transform.basis.z
	forward = forward.slide(Vector3.UP).normalized()
	var move := forward*move_input.y + right*move_input.x
	global_position += Vector3(move.x, 0, move.z)*move_speed*delta
	
	global_rotation.y += Input.get_axis('ui_left', 'ui_right')*delta

	if Input.is_action_just_pressed('zoom_in'):
		camera.position.z -= 1
	elif Input.is_action_just_pressed('zoom_out'):
		camera.position.z += 1
	else:
		camera.position.z += Input.get_axis('zoom_in', 'zoom_out')
	
	camera.position.z = max(camera.position.z, 5)
