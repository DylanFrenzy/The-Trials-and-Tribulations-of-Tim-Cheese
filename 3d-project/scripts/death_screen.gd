extends Control

@onready var button = $Button
var wave_count;

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	button.text = "You Died At Wave " + str(wave_count)
	get_tree().create_timer(4).timeout.connect(restart)
	
func restart():
	get_tree().change_scene_to_file("res://scenes/hud/start_screen.tscn")
	queue_free()
