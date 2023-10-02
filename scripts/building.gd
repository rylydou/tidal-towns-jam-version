class_name Building extends Area3D

@export var info_name = ''
@export_multiline var info_description = ''

@export_category('Reclaim')
@export var can_destroy = true
@export var reclaim_cost = 0
@export var reclaim_money = 0
@export var reclaim_wood = 0
@export var reclaim_stone = 0
@export var reclaim_steel = 0

@export_category('Income')
@export var wood_income = 0
@export var stone_income = 0
@export var steel_income = 0
@export var money_income = 0

@onready var label: Label3D = %Label
@export var is_built := false

var is_reclaimed = false
var is_sunk = false
var will_sink = false

@onready var warning_color = Color.from_string('#e6482e', Color.RED)
@onready var normal_color = Color.WHITE

func _enter_tree() -> void:
	input_event.connect(_on_input_event)
	Game.water_level_changed.connect(water_level_changed)
	Game.building_special.connect(special)

func water_level_changed() -> void:
	will_sink = position.y <= Game.next_water_level
	label.text = '!'
	label.modulate = warning_color if will_sink else normal_color
	label.visible = will_sink
	
	if position.y <= Game.current_water_level:
		sink()

func special() -> void:
	if is_sunk: return
		
	Game.wood += wood_income
	Game.stone += stone_income
	Game.steel += steel_income
	Game.money += money_income

func _on_input_event(camera: Node, event: InputEvent, position: Vector3, normal: Vector3, shape_idx: int) -> void:
	var mouse_event = event as InputEventMouseButton
	if not mouse_event: return
		
	if is_instance_valid(Game.building): return
	
	if Input.is_action_just_pressed("add_all", true):
		_add_all()
		
	elif Input.is_action_just_pressed('add', true):
		_add()
		
	if Input.is_action_just_pressed("sub_all"):
		_sub_all()

	elif Input.is_action_just_pressed('sub'):
		_sub()

func _add() -> void:
	pass
	
func _add_all() -> void:
	pass

func _sub() -> void:
	if can_destroy && is_built:
		reclaim()

func _sub_all() -> void:
	pass

func reclaim() -> void:
	if is_sunk: return
	if is_reclaimed: return
	if Game.money < reclaim_cost: return
	is_reclaimed = true
	Game.money -= reclaim_cost
	
	Game.money += reclaim_money
	Game.wood += reclaim_wood
	Game.stone += reclaim_stone
	Game.steel += reclaim_steel
	SoundBank.play_ui('destroy')
	queue_free()

func sink() -> void:
	SoundBank.play_ui('sink')
	if is_sunk: return
	if is_reclaimed: return
	is_sunk = true
	var tween = create_tween()
	tween.tween_property(self, 'position:y', position.y - 10, 2.5).set_delay(1.0)

func test_placement(floor_valid: bool) -> bool:
	var is_valid = floor_valid
	if get_overlapping_areas().size() > 0: is_valid = false
	if position.y <= Game.current_water_level: is_valid = false
	
	label.visible = not is_valid
	label.modulate = warning_color
	label.text = 'X'
	return is_valid
