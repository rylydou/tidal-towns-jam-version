extends Control

signal next_day()
signal water_level_changed()

var day = 0

@export var win_screen: Control
@export var fail_screen: Control

@export var people_label: Label

@export var money_label: Label
@export var wood_label: Label
@export var stone_label: Label
@export var steel_label: Label
@export var day_button: Button

var people = 0

var money = 0
var wood = 0
var stone = 0
var steel = 0

var is_failed = false

var current_water_level = 0.0
var next_water_level = 0.0
var max_water_level = 1

func _ready() -> void:
	restart()

func _process(delta: float) -> void:
	people_label.position = get_local_mouse_position()
	people_label.position.y -= people_label.size.y
	people_label.position.x += 16.
	
	people_label.visible = people > 0
	people_label.text = str(people,' people')
	money_label.text = str('Money: ',money)
	wood_label.text = str('Wood: ',wood)
	stone_label.text = str('Stone: ',stone)
	steel_label.text = str('Steel: ',steel)
	day_button.text = str('Next day ',day,'/',max_water_level)
	
	if Input.is_action_just_pressed('debug_give_mats', true):
		money += 10
		wood += 10
		stone += 10
		steel += 10
		return

func restart() -> void:
	day = 0
	people = 0
	is_failed = false
	
	get_tree().reload_current_scene()
	
	# await get_tree().process_frame
	# await get_tree().process_frame
	await get_tree().process_frame
	
	next_day.emit()
	water_level_changed.emit()
	
	win_screen.hide()
	fail_screen.hide()

func win() -> void:
	win_screen.show()

func fail() -> void:
	fail_screen.show()
	is_failed = true

func _on_retry_button_pressed() -> void:
	restart()

func _on_next_button_pressed() -> void:
	if day >= max_water_level:
		restart()
		return
	
	day += 1
	
	next_day.emit()
	water_level_changed.emit()
