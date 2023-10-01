extends Control

signal next_day()
signal water_level_changed()
signal building_special()

@export var win_screen: Control
@export var fail_screen: Control

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
var current_level
var level_number := 0

var current_water_level := 0.0
var next_water_level := 0.0

var people := 0
var build: Build
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
		build_menu.add_child(build_button)
	
	body_ray = RayCast3D.new()
	add_child(body_ray)
	body_ray.collide_with_areas = false
	body_ray.collide_with_bodies = true
	
	area_ray = RayCast3D.new()
	add_child(area_ray)
	area_ray.collide_with_areas = true
	area_ray.collide_with_bodies = false
	current_level = levels[level_number].instantiate()
	tutorial_label.text = current_level.tutorial_messages[0]
	
	restart()

func _process(delta: float) -> void:
	people_label.position = get_local_mouse_position()
	people_label.position.y -= people_label.size.y
	people_label.position.x += 16.
	
	people_label.visible = people > 0
	people_label.text = str(people,' people')
	money_label.text = str('Gold: ',money)
	wood_label.text = str('Wood: ',wood)
	stone_label.text = str('Stone: ',stone)
	steel_label.text = str('Steel: ',steel)
	if !day == max_day:
		day_button.text = str('Next day ',day + 1,'/',max_day + 1)
	else:
		day_button.text = "Finish Level"
	
	cast_ray()
	
	var floor_valid := body_ray.get_collision_normal().y == 1.
	
	var obj: Building
	if area_ray.is_colliding():
		obj = area_ray.get_collider() as Building
	
	info_control.visible = is_instance_valid(obj)
	if obj:
		info_name_label.text = obj.info_name
		info_description_label.text = obj.info_description
	
	if building:
		building.position = body_ray.get_collision_point()
		building.rotation.y += (float(Input.is_action_pressed("spin_left")) - float(Input.is_action_pressed("spin_right"))) * delta * spin_speed
		building.test_placement(floor_valid)
	

	if Input.is_action_just_pressed('add'):
		if building:
			if not building.test_placement(floor_valid):
				return
			
			building.water_level_changed()
			money -= build.cost_money
			wood -= build.cost_wood
			stone -= build.cost_stone
			steel -= build.cost_steel
			
			building = null
			return
		
		if people > 0:
			return
	
	if Input.is_action_just_pressed('sub'):
		if building:
			building.queue_free()
			building = null
			return
		
		if people > 0:
			return
	
	if Input.is_action_just_pressed('debug_give_mats', true):
		money += 10
		wood += 10
		stone += 10
		steel += 10
		return
		
	if Input.is_action_just_pressed("next_message"):
		if message_num < current_level.tutorial_messages.size() - 1:
			message_num+=1
			tutorial_label.text = current_level.tutorial_messages[message_num]
		else:
			tutorial_container.visible = false
func cast_ray() -> void:
	if not is_instance_valid(camera): return
	body_ray.position = camera.global_position
	body_ray.target_position = body_ray.position + camera.project_ray_normal(get_local_mouse_position())*1000
	body_ray.force_raycast_update()
	
	area_ray.position = body_ray.position
	area_ray.target_position = body_ray.target_position
	area_ray.force_raycast_update()

func start_build(build: Build) -> void:
	if money < build.cost_money: return
	if wood < build.cost_wood: return
	if stone < build.cost_stone: return
	if steel < build.cost_steel: return
	
	self.build = build
	
	building = build.scene.instantiate() as Building
	get_tree().current_scene.add_child(building)

func restart() -> void:
	day = 0
	people = 0
	is_failed = false
	
	get_tree().reload_current_scene()
	
	await get_tree().process_frame
	
	camera = get_tree().current_scene.find_child('Camera')
	
	next_day.emit()
	await get_tree().process_frame
	water_level_changed.emit()

func win() -> void:
	win_screen.show()

func fail() -> void:
	fail_screen.show()
	is_failed = true

func _on_retry_button_pressed() -> void:
	restart()

func _on_next_button_pressed() -> void:
	if day >= max_day:
		next_level()
		return
	
	day += 1
	
	next_day.emit()
	water_level_changed.emit()
	building_special.emit()

func next_level():
	level_number += 1
	day = 0
	get_tree().change_scene_to_packed(levels[level_number])
	current_level = levels[level_number].instantiate()
	if current_level.tutorial_messages.size() > 0:
		tutorial_label.text = current_level.tutorial_messages[0]
	message_num = 0
