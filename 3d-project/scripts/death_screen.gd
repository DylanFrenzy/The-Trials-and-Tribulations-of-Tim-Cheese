extends Control

@onready var button = $Button
var wave_count;

func _ready():
	button.text = "You Died At Wave " + str(wave_count)
	get_tree().create_timer(2).timeout.connect(restart)
	
func restart():
	get_tree().change_scene_to_file("res://scenes/hud/start_screen.tscn")
	queue_free()
