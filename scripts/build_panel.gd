extends Control

func _process(delta: float) -> void:
	var target: float
	
	var mouse_position := get_global_mouse_position()
	var is_visible := get_global_rect().has_point(mouse_position)
	
	if mouse_position.y >= get_parent().size.y:
		is_visible = false
	
	if Game.people > 0 or is_instance_valid(Game.building):
		is_visible = false
	
	if is_visible:
		target = get_parent().size.y - size.y
	else:
		target = get_parent().size.y - 48
	
	# position.y = lerp(position.y, target, .25)
	position.y = lerp(target, position.y, exp(delta * -10))
