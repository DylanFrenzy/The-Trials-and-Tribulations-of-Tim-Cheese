extends Node3D

@onready var johnnie : PackedScene = preload("res://assets/John_Pork.tscn")
@onready var enemy_spawn_path = $EnemySpawnPath/PathFollow3D
@onready var wave_display = $hud/wave_display
@onready var enemy_counter = $hud/EnemyCounter
var wave = 1
var enemies_spawned = []
var difficulty;

func _ready():
	$Player.player_death.connect(_on_player_death)
	spawn_enemy_wave(wave);
	set_enemy_counter()
	
func spawn_enemy_wave(wave_count):
	wave_display.text = "Wave " + str(wave_count)
	for i in range(wave_count * difficulty):
		var enemy_instance = johnnie.instantiate();
		enemy_instance.enemy_death.connect(_on_enemy_death);
		enemies_spawned.append(enemy_instance)
		enemy_spawn_path.progress_ratio = randf();
		enemy_instance.position = enemy_spawn_path.position;
		add_child(enemy_instance)
		
func set_enemy_counter():
	enemy_counter.text = "Enemies remaining this wave: " + str(enemies_spawned.size())
		
func _on_enemy_death():
	enemies_spawned.pop_back()
	if enemies_spawned.is_empty():
		wave += 1
		spawn_enemy_wave(wave)
	set_enemy_counter()
		
func _on_player_death():
	var death_screen = preload("res://scenes/hud/death_screen.tscn").instantiate()
	death_screen.wave_count = wave
	get_tree().root.call_deferred("add_child", death_screen)
	call_deferred("queue_free")
