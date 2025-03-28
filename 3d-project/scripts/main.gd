extends Node3D

@onready var johnnie : PackedScene = preload("res://assets/John_Pork.tscn")
@onready var enemy_spawn_path = $EnemySpawnPath/PathFollow3D
@onready var wave_display = $CanvasLayer/wave_display
var wave = 1
var enemies_spawned = []

func _ready():
	spawn_enemy_wave(wave);

func spawn_enemy_wave(wave_count):
	wave_display.text = "Wave " + str(wave_count)
	for i in range(wave_count):
		var enemy_instance = johnnie.instantiate();
		enemy_instance.enemy_death.connect(on_enemy_death);
		enemies_spawned.append(enemy_instance)
		enemy_spawn_path.progress_ratio = randf();
		enemy_instance.position = enemy_spawn_path.position;
		add_child(enemy_instance)
		
func on_enemy_death():
	enemies_spawned.pop_back()
	if enemies_spawned.is_empty():
		wave += 1
		spawn_enemy_wave(wave)
