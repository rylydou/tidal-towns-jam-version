class_name Building extends Area3D

@export var info_name = ''
@export_multiline var info_description = ''
@export var fail_on_sink = false

@export_category('Reclaim')
@export var reclaim_cost = 0
@export var reclaim_money = 0
@export var reclaim_wood = 0
@export var reclaim_stone = 0
@export var reclaim_steel = 0

@export_group('Other')
@export var normal_color := Color.WHITE
@export var warning_color := Color.RED

@onready var label: Label3D = %Label

var is_reclaimed = false

func _enter_tree() -> void:
	input_event.connect(_on_input_event)
	Game.water_level_changed.connect(water_level_changed)

func water_level_changed() -> void:
	var will_sink = position.y <= Game.next_water_level
	if fail_on_sink:
		label.modulate = warning_color if will_sink else normal_color
		label.visible = will_sink
	
	if position.y <= Game.current_water_level:
		if fail_on_sink:
			Game.fail()
		var tween = create_tween()
		tween.tween_property(self, 'position:y', position.y - 10, 2.5).set_delay(1.0)

func _on_input_event(camera: Node, event: InputEvent, position: Vector3, normal: Vector3, shape_idx: int) -> void:
	var mouse_event = event as InputEventMouseButton
	if not mouse_event: return
	
	if Input.is_action_just_pressed('add'):
		_add()
		return

	if Input.is_action_just_pressed('sub'):
		_sub()
		return

func _add() -> void:
	pass

func _sub() -> void:
	reclaim()

func reclaim() -> void:
	if is_reclaimed: return
	if Game.money < reclaim_cost: return
	is_reclaimed = true
	Game.money -= reclaim_cost
	
	Game.money += reclaim_money
	Game.wood += reclaim_wood
	Game.stone += reclaim_stone
	Game.steel += reclaim_steel
	queue_free()

func test_placement(floor_valid: bool) -> bool:
	var is_valid = floor_valid
	if get_overlapping_areas().size() > 0: is_valid = false
	# if get_overlapping_bodies().size() > 1: is_valid = false
	
	label.visible = not is_valid
	label.modulate = warning_color
	label.text = 'X'
	return is_valid
