extends Control

@onready var starting_y = position.y

func _on_mouse_exited() -> void:
	# position.y = starting_y + 1000
	pass

func _on_mouse_entered() -> void:
	# position.y = starting_y
	pass
