class_name Building extends Area3D

@export_category('Inhabitants')
@export var current_inhabitants = 0
@export var max_inhabitants = 0

@export_category('Build')
@export var build_cost = 0
@export var build_wood = 0
@export var build_stone = 0
@export var build_steel = 0

@export_category('Reclaim')
@export var reclaim_wood = 0
@export var reclaim_stone = 0
@export var reclaim_steel = 0

var is_reclaimed = false

func _enter_tree() -> void:
	input_event.connect(_on_input_event)
	Game.update_buildings.connect(update)

func update() -> void:
	if position.y <= Game.current_water_level:
		Game.fail()

func _process(delta: float) -> void:
	%PopulationLabel.modulate = Color.RED if position.y <= Game.next_water_level else Color.WHITE
	# %PopulationLabel.visible = current_inhabitants > 0
	%PopulationLabel.text = str(current_inhabitants,'/',max_inhabitants)

func _on_input_event(camera: Node, event: InputEvent, position: Vector3, normal: Vector3, shape_idx: int) -> void:
	var mouse_event = event as InputEventMouseButton
	if not mouse_event: return
		
	if Input.is_action_just_pressed('add'):
		if Game.people > 0 and current_inhabitants < max_inhabitants:
			current_inhabitants += 1
			Game.people -= 1
		return
	
	if Input.is_action_just_pressed('sub'):
		if current_inhabitants <= 0 and Game.people <= 0:
			reclaim()
		elif current_inhabitants > 0:
			current_inhabitants -= 1
			Game.people += 1
		return

func reclaim() -> void:
	if is_reclaimed: return
	is_reclaimed = true
	
	Game.wood += reclaim_wood
	Game.stone += reclaim_stone
	Game.steel += reclaim_steel
	queue_free()
