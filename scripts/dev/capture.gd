extends Node

@export_dir var capture_path := 'user://'
@export var root_size := Vector2i(630, 500)
@export var msaa_2d := RenderingServer.VIEWPORT_MSAA_MAX
@export var msaa_3d := RenderingServer.VIEWPORT_MSAA_MAX

func _ready() -> void:
	update_root_size()
	RenderingServer.viewport_set_msaa_2d(get_viewport(), msaa_2d)
	RenderingServer.viewport_set_msaa_3d(get_viewport(), msaa_3d)

func _process(delta: float) -> void:
	if Input.is_action_just_pressed('add'):
		update_root_size()
		capture()

func update_root_size() -> void:
	get_tree().root.size = root_size

func capture() -> void:
	var image := get_viewport().get_texture().get_image()
	var time_string := Time.get_datetime_string_from_system()
	var filename := time_string
	filename = filename.replace(':', '-')
	image.save_png(str(capture_path,filename,'.png'))
