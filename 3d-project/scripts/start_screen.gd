extends Control

var main_game_scene_path = "res://scenes/main.tscn"

func _on_button_pressed() -> void:
	get_tree().change_scene_to_file(main_game_scene_path) # Replace with function body.
