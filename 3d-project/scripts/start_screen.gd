extends Control

@onready var load_bar = $ProgressBar;
@onready var difficulty_label = $Difficulty
@onready var easier_button = $Difficulty/Easier
@onready var harder_button = $Difficulty/Harder

var main_game_scene_path;
var progress_value = 0.00;
var is_loading = false
var difficulties = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
var difficulty_index = 0

func _ready() -> void:
	update_difficulty_display()

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
		var instance = loaded_scene.instantiate()
		instance.difficulty = difficulties[difficulty_index]
		get_tree().root.call_deferred("add_child", instance)
		call_deferred("queue_free")
			
func load_bar_start():
	main_game_scene_path = "res://scenes/main.tscn"
	ResourceLoader.load_threaded_request(main_game_scene_path)
			
func _on_button_pressed() -> void:
	$Button.disabled = true
	load_bar_start()
	
func update_difficulty_display():
	difficulty_label.text = "Difficulty: " + str(difficulties[difficulty_index])
	easier_button.disabled = true if difficulty_index == 0 else false
	harder_button.disabled = true if difficulty_index == 9 else false
	
func _on_easier_pressed() -> void:
	difficulty_index -= 1
	update_difficulty_display()

func _on_harder_pressed() -> void:
	difficulty_index += 1
	update_difficulty_display()
