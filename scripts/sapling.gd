extends Building

@export var tree_scene: PackedScene

func special() -> void:
	if is_sunk: return
	super.special()
	
	var tree: Building = tree_scene.instantiate()
	tree.transform = transform
	get_tree().process_frame.connect(tree.water_level_changed, Node.CONNECT_ONE_SHOT)
	get_parent().add_child(tree)
	
	SoundBank.play_3d('tree_grow', global_position)
	
	queue_free()
