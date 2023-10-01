class_name Home extends Building

@export_category('Inhabitants')
@export var current_inhabitants = 0
@export var max_inhabitants = 0

func update_label() -> void:
	label.text = str(current_inhabitants,'/',max_inhabitants)

func water_level_changed() -> void:
	super.water_level_changed()
	
	update_label()
	
	label.show()

func _add() -> void:
	if Game.people > 0 and current_inhabitants < max_inhabitants:
		current_inhabitants += 1
		Game.people -= 1
		update_label()

func _add_all() -> void:
	while(Game.people > 0 and current_inhabitants < max_inhabitants):
		current_inhabitants += 1
		Game.people -= 1
		update_label()

func _sub() -> void:
	if current_inhabitants <= 0 and Game.people <= 0:
		if can_destroy && is_built:
			reclaim()
		return
	
	if current_inhabitants > 0:
		current_inhabitants -= 1
		Game.people += 1
		update_label()
		return

func _sub_all() -> void:
	while(current_inhabitants > 0):
		current_inhabitants -= 1
		Game.people += 1
		update_label()
