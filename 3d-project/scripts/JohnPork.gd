extends CharacterBody3D;

signal enemy_death

@export var speed = 2;
@export var health = 20;
@export var attack_range = 5;

@onready var player = get_tree().root.get_node("Node3D/CharacterBody3D");;
@onready var ani_player = $AnimationPlayer;
	
func _physics_process(delta):
	var distance_to_player = global_transform.origin.distance_to(player.global_transform.origin);
	if distance_to_player <= attack_range:
		attack();
		
	var direction = (player.global_transform.origin - global_transform.origin).normalized();
	velocity = direction * speed;
	move_and_slide();
	
func attack():
	pass;
	
func take_damage(damage):
	health -= damage;
	if health <= 0:
		emit_signal("enemy_death")
		die();
		return;
	ani_player.play("damage_taken");

func die():
	queue_free();
	
