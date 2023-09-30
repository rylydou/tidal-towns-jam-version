extends Control

signal next_day()
signal water_level_changed()
signal building_special()

@export var win_screen: Control
@export var fail_screen: Control

@export var info_control: Control
@export var info_name_label: Label
@export var info_description_label: Label

@export var build_menu: Control

@export var people_label: Label

@export var money_label: Label
@export var wood_label: Label
@export var stone_label: Label
@export var steel_label: Label
@export var day_button: Button

@export var builds: Array[Build] = []

var money := 0
var wood := 0
var stone := 0
var steel := 0

var is_failed = false

var day := 0
var max_day := 1

var current_water_level := 0.0
var next_water_level := 0.0

var people := 0
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
	body_ray.collide_with_areas = false
	body_ray.collide_with_bodies = true
	add_child(body_ray)
	
	area_ray = RayCast3D.new()
	add_child(area_ray)
	area_ray.collide_with_areas = true
	area_ray.collide_with_bodies = false
	
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
	day_button.text = str('Next day ',day,'/',max_day)
	
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
		building.test_placement(floor_valid)
	
	if Input.is_action_just_pressed('add'):
		if building:
			if building.test_placement(floor_valid):
				building.water_level_changed()
			else:
				building.queue_free()
			
			building = null
			return
		
		if people > 0:
			return
	
	if Input.is_action_just_pressed('sub'):
		if building:
			return
		
		if people > 0:
			return
	
	if Input.is_action_just_pressed('debug_give_mats', true):
		money += 10
		wood += 10
		stone += 10
		steel += 10
		return

func cast_ray() -> void:
	body_ray.position = camera.global_position
	body_ray.target_position = body_ray.position + camera.project_ray_normal(get_local_mouse_position())*1000
	body_ray.force_raycast_update()
	
	area_ray.position = body_ray.position
	area_ray.target_position = body_ray.target_position
	area_ray.force_raycast_update()

func start_build(build: Build) -> void:
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
		restart()
		return
	
	day += 1
	
	next_day.emit()
	water_level_changed.emit()
	building_special.emit()