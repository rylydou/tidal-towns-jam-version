class_name Building extends Area3D

@export_category('Reclaim')
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
	var is_sunk = position.y <= Game.next_water_level
	label.modulate = warning_color if is_sunk else normal_color
	label.visible = is_sunk
	
	if position.y <= Game.current_water_level:
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
	is_reclaimed = true
	
	Game.wood += reclaim_wood
	Game.stone += reclaim_stone
	Game.steel += reclaim_steel
	queue_free()
