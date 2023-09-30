class_name Level extends Node3D

@export var starting_money := 0
@export var starting_wood := 0
@export var starting_stone := 0
@export var starting_steel := 0

@export var water_levels: Array[float] = [0.0]

# @export_region('References')
@export var water: Node3D

func _ready() -> void:
	Game.money = starting_money
	Game.wood = starting_wood
	Game.stone = starting_stone
	Game.steel = starting_steel
	
	Game.max_water_level = water_levels.size() - 1
	update_water_level()
	
	Game.next_day.connect(_on_next_day)

func update_water_level() -> void:
	Game.current_water_level = water_levels[Game.day]
	if Game.day < water_levels.size() - 1:
		Game.next_water_level = water_levels[Game.day + 1]
	
	var tween := create_tween()
	tween.tween_property(water, 'position:y', Game.current_water_level, 1.0)

func _on_next_day() -> void:
	update_water_level()
