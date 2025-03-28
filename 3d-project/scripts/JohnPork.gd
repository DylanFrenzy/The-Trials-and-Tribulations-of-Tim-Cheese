extends CharacterBody3D;

signal enemy_death

@export var speed = 4;
@export var health = 20;
@export var attack_range = 5;
@export var turn_speed = 3;

@onready var player = get_tree().root.get_node("Node3D/CharacterBody3D");;
@onready var ani_player = $AnimationPlayer;
@onready var mesh = $MeshInstance3D
	
func _physics_process(delta):
	var distance_to_player = position.distance_to(player.position);
	var direction = (player.position - position).normalized();
	look_at(player.position, Vector3.UP)
	rotate_y(deg_to_rad(90))
	if distance_to_player <= attack_range:
		attack();
	velocity = direction * speed;
	move_and_slide();
	
func attack():
	ani_player.play("attack");
	
func take_damage(damage):
	health -= damage;
	if health <= 0:
		emit_signal("enemy_death")
		die();
	else:
		var material = mesh.get_surface_override_material(0).duplicate()
		mesh.set_surface_override_material(0, material)
		var og_color = material.albedo_color
		material.albedo_color = Color.RED
		await get_tree().create_timer(0.1).timeout
		material.albedo_color = og_color

func die():
	queue_free();
	
