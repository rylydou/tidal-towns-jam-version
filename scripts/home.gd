class_name Home extends Building

@export_category('Inhabitants')
@export var current_inhabitants = 0
@export var max_inhabitants = 0

func _process(delta: float) -> void:
	# label.visible = current_inhabitants > 0
	label.text = str(current_inhabitants,'/',max_inhabitants)

func water_level_changed() -> void:
	super.water_level_changed()
	
	label.show()

func _add() -> void:
	if Game.people > 0 and current_inhabitants < max_inhabitants:
		current_inhabitants += 1
		Game.people -= 1

func _sub() -> void:
	if current_inhabitants <= 0 and Game.people <= 0:
		reclaim()
		return
	
	if current_inhabitants > 0:
		current_inhabitants -= 1
		Game.people += 1
		return
