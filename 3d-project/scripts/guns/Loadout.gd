extends Node

var filepath = "res://assets/guns"
var gun_instances = [];
var current_gun = 0

func _ready() -> void:
	var dir = DirAccess.open(filepath)
	if dir:
		dir.list_dir_begin()
		var file = dir.get_next()
		while file != "":
			var scene = load(filepath + "/" + file)
			var instance = scene.instantiate()
			gun_instances.append(instance);
			file = dir.get_next();
		dir.list_dir_end();
	add_child(gun_instances[current_gun])

func _input(event: InputEvent) -> void:
	if (event.is_action_pressed("swap_weapon")):
		swap_weapon();
		
func swap_weapon():
	for child in get_children():
		remove_child(child);
	current_gun = 0 if current_gun == 1 else 1
	add_child(gun_instances[current_gun])
	gun_instances[current_gun].update_ammo_display(gun_instances[current_gun].current_ammo)
	
	
