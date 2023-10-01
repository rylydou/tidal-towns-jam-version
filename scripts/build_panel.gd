extends Control

func _physics_process(delta: float) -> void:
	var target: float
	
	var is_visible := get_global_rect().has_point(get_global_mouse_position())
	
	if Game.people > 0 or is_instance_valid(Game.building):
		is_visible = false
	
	if is_visible:
		target = get_parent().size.y - size.y
	else:
		target = get_parent().size.y - 48
	
	position.y = lerp(position.y, target, .25)
