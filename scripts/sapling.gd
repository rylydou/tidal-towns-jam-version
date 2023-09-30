extends Building

@export var tree_scene: PackedScene

func special() -> void:
	if is_sunk: return
	super.special()
	
	var tree: Building = tree_scene.instantiate()
	tree.transform = transform
	get_parent().add_child(tree)
	
	queue_free()
