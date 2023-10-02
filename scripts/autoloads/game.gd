extends Control

signal next_day()
signal water_level_changed()
signal building_special()

@export var fail_screen: Control
@export var win_screen: Control

@export var info_control: Control
@export var info_name_label: Label
@export var info_description_label: Label

@export var tutorial_container: PanelContainer
var message_num = 0
@export var tutorial_label: Label

@export var build_menu: Control

@export var people_label: Label

@export var money_label: Label
@export var wood_label: Label
@export var stone_label: Label
@export var steel_label: Label
@export var day_button: Button

@export var builds: Array[Build] = []

@export var spin_speed := 2.0

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
		build_menu.add_child(build_button)
	
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

func _process(delta: float) -> void:
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
		info_description_label.text = obj.info_description
	
	if is_instance_valid(building):
		building.position = body_ray.get_collision_point()
		building.rotation.y += Input.get_axis("spin_left", "spin_right") * delta * spin_speed
		building.test_placement(floor_valid)
	
	if Input.is_action_just_pressed('add'):
		if is_instance_valid(building):
			if not building.test_placement(floor_valid):
				SoundBank.play_ui('build_invalid')
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
				SoundBank.play_ui('build_confirm')
			return
	
	if Input.is_action_just_pressed('sub'):
		if is_instance_valid(building):
			SoundBank.play_ui('build_cancel')
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
		SoundBank.play_ui('tutorial_next')
		
		if message_num < get_tree().current_scene.tutorial_messages.size() - 1:
			message_num += 1
			tutorial_label.text = get_tree().current_scene.tutorial_messages[message_num]
		else:
			tutorial_container.hide()
		return

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
	message_num = 0
	
	fail_screen.hide()
	win_screen.hide()
	
	get_tree().reload_current_scene()
	
	await get_tree().process_frame
	
	camera = get_tree().current_scene.find_child('Camera')
	tutorial_container.hide()
	if get_tree().current_scene.tutorial_messages.size() > 0:
		tutorial_label.text = get_tree().current_scene.tutorial_messages[0]
		tutorial_container.show()
	
	next_day.emit()
	
	await get_tree().process_frame
	
	water_level_changed.emit()
	calc_til_rise()

func win() -> void:
	if is_failed: return
	
	SoundBank.play_ui('win')
	win_screen.show()

func fail() -> void:
	SoundBank.play_ui('fail')
	fail_screen.show()
	is_failed = true

func _on_retry_button_pressed() -> void:
	SoundBank.play_ui('retry')
	restart()

func _on_next_button_pressed() -> void:
	if is_failed: return
	
	if day >= max_day - 1:
		win_screen.show()
	
	SoundBank.play_ui('next_day')
	
	if day >= max_day: return
	
	day += 1
	
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
	
	restart()
	
	if level_number >= levels.size() - 1:
		%NextButton.hide()

func calc_til_rise():
	for raise_day in raise_days:
		if day >= raise_day: continue
		
		if raise_day - day == 1:
			%DaysTilLabel.label_settings.font_color = Color(.9,.28,.18)
			%DaysTilLabel.text = str(raise_day - day,' day til sea levels rise')
		else:
			%DaysTilLabel.label_settings.font_color = Color.WHITE
			%DaysTilLabel.text = str(raise_day - day,' days til sea levels rise')
		break
