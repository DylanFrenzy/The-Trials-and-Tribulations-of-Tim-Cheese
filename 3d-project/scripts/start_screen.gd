extends Control

@onready var load_bar = $ProgressBar;

var main_game_scene_path;
var progress_value = 0.00;
var is_loading = false

func load_bar_start():
	main_game_scene_path = "res://scenes/main.tscn"
	ResourceLoader.load_threaded_request(main_game_scene_path)
	
func _process(delta: float) -> void:
	if not main_game_scene_path:
		return;
		
	var progress = []
	var status = ResourceLoader.load_threaded_get_status(main_game_scene_path, progress)
	
	if status == ResourceLoader.ThreadLoadStatus.THREAD_LOAD_IN_PROGRESS:
		progress_value = progress[0] * 100;
		load_bar.value = move_toward(load_bar.value, progress_value, delta * 20);
	
	if status == ResourceLoader.ThreadLoadStatus.THREAD_LOAD_LOADED:
		load_bar.value = move_toward(load_bar.value, 100.0, delta * 150)
		
		if load_bar.value >= 99:
			var loaded_scene = ResourceLoader.load_threaded_get(main_game_scene_path)
			if loaded_scene: get_tree().change_scene_to_packed(loaded_scene);
			
func _on_button_pressed() -> void:
	$Button.disabled = true
	load_bar_start()
