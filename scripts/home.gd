class_name Home extends Building

@export_category('Inhabitants')
@export var current_inhabitants = 0
@export var max_inhabitants = 0

func update_label() -> void:
	if will_sink and current_inhabitants > 0:
		label.modulate = danger_color
	
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
	if current_inhabitants >= max_inhabitants or Game.people <= 0:
		super._add()
		return
	
	var amount = min(max_inhabitants - current_inhabitants, Game.people)
	if amount <= 0: return
	
	current_inhabitants += amount
	Game.people -= amount
	
	var player := SoundBank.play_3d('drop', global_position)
	player.pitch_scale = remap(amount, 0, 25, .5, 1.75)
	update_label()

func _sub() -> void:
	if current_inhabitants <= 0 and Game.people <= 0:
		super._sub()
		return
	
	var amount = current_inhabitants
	if amount <= 0: return
		
	Game.people += amount
	current_inhabitants = 0
	
	var player := SoundBank.play_3d('pickup', global_position)
	player.pitch_scale = remap(amount, 0, 25, .5, 1.75)
	update_label()
