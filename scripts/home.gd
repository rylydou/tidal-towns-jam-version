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
	
func sink():
	super.sink()
	if current_inhabitants > 0:
		Game.fail()

func _add() -> void:
	while Game.people > 0 and current_inhabitants < max_inhabitants:
		SoundBank.play_3d('drop', global_position)
		current_inhabitants += 1
		Game.people -= 1
	
	update_label()

func _sub() -> void:
	if current_inhabitants <= 0 and Game.people <= 0:
		if can_destroy:
			reclaim()
		return
	
	while current_inhabitants > 0:
		SoundBank.play_3d('pickup', global_position)
		current_inhabitants -= 1
		Game.people += 1
	update_label()
