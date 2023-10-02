extends Node

const SOUND_BANK_FOLDER := 'res://resources/sounds/'
const FALLBACK_SOUND: AudioStreamWAV = preload('./fallback.wav')
const POOL_SIZE_3D := 16.
const POOL_SIZE_UI := 8.

var bank := {}

var next_pool_index_3d := 0
var player_pool_3d: Array[AudioStreamPlayer3D] = []
func get_player_3d() -> AudioStreamPlayer3D:
	var player := player_pool_3d[next_pool_index_3d]
	next_pool_index_3d += 1
	if next_pool_index_3d >= player_pool_3d.size():
		next_pool_index_3d = 0
	return player
func generate_pool_3d(count: int) -> void:
	for i in count:
		var player := AudioStreamPlayer3D.new()
		player.bus = &'SFX'
		add_child(player)
		player_pool_3d.append(player)

var next_pool_index_ui := 0
var player_pool_ui: Array[AudioStreamPlayer] = []
func get_player_ui() -> AudioStreamPlayer:
	var player := player_pool_ui[next_pool_index_ui]
	next_pool_index_ui += 1
	if next_pool_index_ui >= player_pool_ui.size():
		next_pool_index_ui = 0
	return player
func generate_pool_ui(count: int) -> void:
	for i in count:
		var player := AudioStreamPlayer.new()
		player.process_mode = Node.PROCESS_MODE_ALWAYS
		player.bus = &'UI'
		add_child(player)
		player_pool_ui.append(player)

func _ready() -> void:
	generate_pool_3d(POOL_SIZE_3D)
	generate_pool_ui(POOL_SIZE_UI)
	if not DirAccess.dir_exists_absolute(SOUND_BANK_FOLDER):
		printerr('[SoundBank] Sound bank folder not found at %s' % SOUND_BANK_FOLDER)
	print(DirAccess.get_files_at(SOUND_BANK_FOLDER))

var loaded_sounds := {}
func get_sound(name: String) -> AudioStream:
	if loaded_sounds.has(name):
		return loaded_sounds[name]
	
	var sound: AudioStream = FALLBACK_SOUND
	var segs := name.split('.')
	
	while segs.size() > 0:
		var path := SOUND_BANK_FOLDER + '.'.join(segs)
		if FileAccess.file_exists(path + '.wav.import'):
			sound = load(path + '.wav')
			break
		if FileAccess.file_exists(path + '.ogg'):
			sound = load(path + '.ogg')
			break
		if FileAccess.file_exists(path + '.ogg.import'):
			sound = load(path + '.ogg')
		break
		segs.remove_at(segs.size() - 1)
	
	loaded_sounds[name] = sound
	return sound

func play_3d(name: String, position: Vector3, bus: StringName = &'SFX') -> void:
	var player := get_player_3d()
	var sound := get_sound(name)
	player.stop()
	player.stream = sound
	player.position = position
	player.pitch_scale = randf_range(0.9, 1.1)
	player.volume_db = randf_range(-2.5, 2.5)
	player.bus = bus
	player.play()

func play_ui(name: String, bus: StringName = &'UI') -> void:
	var player := get_player_ui()
	var sound := get_sound(name)
	player.stop()
	player.stream = sound
	player.bus = bus
	player.play()
