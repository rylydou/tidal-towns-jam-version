extends Control

signal next_day()
signal water_level_changed()
signal building_special()

@export var spin_speed := 2.0
@export var builds: Array[Build] = []

@onready var fail_screen: Control = %'Fail'
@onready var win_screen: Control = %'Win'
@onready var start_screen: Control = %'Start'

@onready var info_control: Control = %'Info'
@onready var info_name_label: Label = %'Info Name'
@onready var info_text_label: Label = %'Info Text'

@onready var tutorial_control: Control = %'Tut'
@onready var tutorial_text: Label = %'Tut Text'

@onready var build_contents: Control = %'Build Contents'

@onready var people_label: Label = %'People Tooltip'

@onready var money_label: Label = %'Money'
@onready var wood_label: Label = %'Wood'
@onready var stone_label: Label = %'Stone'
@onready var steel_label: Label = %'Steel'

@onready var day_button: Button = %'Day Button'
@onready var days_til_label: Label = %'Days Til'

var money := 0
var wood := 0
var stone := 0
var steel := 0

var is_failed = false

var day := 0
var max_day := 1

@export var levels: Array[PackedScene]
var raise_days: Array[int]
var level_number := 0

var current_water_level := 0.0
var next_water_level := 0.0

var people := 0
var build: Build
@export var sapling_build: Build
var building: Building

var tut_msg_index = 0

var body_ray: RayCast3D
var area_ray: RayCast3D
var camera: Camera3D

func _ready() -> void:
	for build in builds:
		var build_button := Button.new()
		build_button.text = build.info_name
		build_button.tooltip_text = build.info_description
		build_button.pressed.connect(func(): start_build(build))
		build_button.alignment = HORIZONTAL_ALIGNMENT_LEFT
		build_button.focus_mode = Control.FOCUS_NONE
		build_contents.add_child(build_button)
	
	body_ray = RayCast3D.new()
	add_child(body_ray)
	body_ray.collide_with_areas = false
	body_ray.collide_with_bodies = true
	
	area_ray = RayCast3D.new()
	add_child(area_ray)
	area_ray.collide_with_areas = true
	area_ray.collide_with_bodies = false
	calc_til_rise()
	
	restart()
	
	if not OS.is_debug_build():
		%StartContainer.show()

func _process(delta: float) -> void:
	if Input.is_action_just_pressed('fullscreen'):
		var window := get_window()
		if window.mode == Window.MODE_FULLSCREEN:
			window.mode = Window.MODE_WINDOWED
		else:
			window.mode = Window.MODE_FULLSCREEN
	
	people_label.position = get_local_mouse_position()
	people_label.position.y -= people_label.size.y
	people_label.position.x += 16.
	people_label.visible = people > 0
	people_label.text = str(people,' ','people' if people > 1 else 'person')
	
	money_label.text = str('Gold: ',money)
	wood_label.text = str('Wood: ',wood)
	stone_label.text = str('Stone: ',stone)
	steel_label.text = str('Steel: ',steel)
	day_button.text = str('Next day ',day + 1,'/',max_day + 1)
	
	cast_ray()
	
	var floor_valid := body_ray.get_collision_normal().y == 1.
	
	var obj: Building
	if area_ray.is_colliding():
		obj = area_ray.get_collider() as Building
	
	info_control.visible = is_instance_valid(obj)
	if obj:
		info_name_label.text = obj.info_name
		info_text_label.text = obj.info_description
	
	if is_instance_valid(building):
		building.position = body_ray.get_collision_point()
		building.rotation.y += Input.get_axis("spin_left", "spin_right") * delta * spin_speed
		building.test_placement(floor_valid)
	
	if Input.is_action_just_pressed('add'):
		if is_instance_valid(building):
			if not building.test_placement(floor_valid):
				SoundBank.play_3d('build_invalid', body_ray.get_collision_point())
				return
			
			building.water_level_changed()
			money -= build.cost_money
			wood -= build.cost_wood
			stone -= build.cost_stone
			steel -= build.cost_steel
			
			if build == sapling_build:
				building = null
				start_build(sapling_build)
			else:
				building = null
				SoundBank.play_3d('build_confirm', body_ray.get_collision_point())
			return
	
	if Input.is_action_just_pressed('sub'):
		if is_instance_valid(building):
			SoundBank.play_3d('build_cancel', body_ray.get_collision_point())
			building.queue_free()
			building = null
			return
	
	if Input.is_action_just_pressed('debug_give_mats', true):
		money += 10
		wood += 10
		stone += 10
		steel += 10
		return
	
	if Input.is_action_just_pressed('debug_win', true):
		win()
		return
	
	if Input.is_action_just_pressed("next_message"):
		next_msg()
		return

func next_msg() -> void:
	if tut_msg_index < get_tree().current_scene.tutorial_messages.size() - 1:
		SoundBank.play_ui('tut_next')
		tut_msg_index += 1
		tutorial_text.text = get_tree().current_scene.tutorial_messages[tut_msg_index]
		return
	
	tutorial_control.hide()

func cast_ray() -> void:
	if not is_instance_valid(camera): return
	body_ray.position = camera.global_position
	body_ray.target_position = body_ray.position + camera.project_ray_normal(get_local_mouse_position())*1000
	body_ray.force_raycast_update()
	
	area_ray.position = body_ray.position
	area_ray.target_position = body_ray.target_position
	area_ray.force_raycast_update()

func start_build(build: Build) -> void:
	if is_instance_valid(building): return
	
	if money < build.cost_money: return
	if wood < build.cost_wood: return
	if stone < build.cost_stone: return
	if steel < build.cost_steel: return
	
	SoundBank.play_ui('build_start')
	
	self.build = build
	building = build.scene.instantiate()
	get_tree().current_scene.add_child(building)

func restart() -> void:
	day = 0
	people = 0
	is_failed = false
	tut_msg_index = 0
	
	fail_screen.hide()
	win_screen.hide()
	
	get_tree().reload_current_scene()
	
	await get_tree().process_frame
	
	camera = get_tree().current_scene.find_child('Camera')
	tutorial_control.hide()
	if get_tree().current_scene.tutorial_messages.size() > 0:
		tutorial_text.text = get_tree().current_scene.tutorial_messages[0]
		tutorial_control.show()
	
	next_day.emit()
	
	await get_tree().process_frame
	
	water_level_changed.emit()
	calc_til_rise()

func win() -> void:
	if is_failed: return
	
	%NextLevelButton.visible = level_number < levels.size() - 1
	
	if level_number >= levels.size() - 1:
		SoundBank.play_ui('win_final')
	else:
		SoundBank.play_ui('win')
	win_screen.show()

func fail() -> void:
	SoundBank.play_ui('fail')
	fail_screen.show()
	win_screen.hide()
	is_failed = true

func _on_retry_button_pressed() -> void:
	SoundBank.play_ui('retry')
	restart()

func _on_next_button_pressed() -> void:
	if is_failed: return
	if people > 0: return
	if is_instance_valid(building): return
	
	if day >= max_day: return
	day += 1
	
	if day >= max_day:
		win()
	else:
		SoundBank.play_ui('next_day')
	
	next_day.emit()
	water_level_changed.emit()
	building_special.emit()
	calc_til_rise()

func next_level():
	if level_number >= levels.size() - 1: return
	
	SoundBank.play_ui('next_level')
	
	level_number += 1
	
	get_tree().change_scene_to_packed(levels[level_number])
	
	await get_tree().process_frame
	await get_tree().process_frame
	await get_tree().process_frame
	
	restart()

func calc_til_rise():
	for raise_day in raise_days:
		if day >= raise_day: continue
		
		if raise_day - day == 1:
			days_til_label.label_settings.font_color = Color(.9,.28,.18)
			days_til_label.text = str(raise_day - day,' day until sea levels rise')
		else:
			days_til_label.label_settings.font_color = Color.WHITE
			days_til_label.text = str(raise_day - day,' days until sea levels rise')
		break


func _on_tutorial_panel_gui_input(event: InputEvent) -> void:
	if Input.is_action_just_pressed('add'):
		next_msg()


func _on_start_pressed():
	start_screen.hide()
