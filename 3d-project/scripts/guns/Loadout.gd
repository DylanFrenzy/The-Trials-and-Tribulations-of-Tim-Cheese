extends Node

var filepath = "res://assets/guns"
var gun_scenes = [];
var gun_instances = {};
var current_gun = 0

func _ready() -> void:
	var dir = DirAccess.open(filepath)
	if dir:
		dir.list_dir_begin()
		var file = dir.get_next()
		while file != "":
			var scene = load(filepath + "/" + file)
			gun_scenes.append(scene);
			file = dir.get_next();
		dir.list_dir_end();
	swap_weapon(current_gun)

func _input(event: InputEvent) -> void:
	if (event.is_action_pressed("swap_weapon_down")):
		current_gun = (current_gun + 1) % gun_scenes.size()
		swap_weapon(current_gun);
	
	if (event.is_action_pressed("swap_weapon_up")):#
		current_gun = (current_gun - 1 + gun_scenes.size()) % gun_scenes.size()
		swap_weapon(current_gun);
		
		
func swap_weapon(to_swap):
	for child in get_children():
		remove_child(child);
	
	if (gun_instances.has(to_swap)):
		var instance = gun_instances[to_swap]
		print(instance.position)
		add_child(instance)
		instance.update_ammo_display(instance.current_ammo)
	else:
		var instance = gun_scenes[to_swap].instantiate()
		gun_instances[to_swap] = instance
		add_child(instance)
		instance.position = instance.set_position
		print(instance.position)
		instance.update_ammo_display(instance.current_ammo)
		
		
	
	
