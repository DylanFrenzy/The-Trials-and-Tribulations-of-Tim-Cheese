extends CharacterBody3D;

@export var speed = 2;
@export var health = 20;
@export var attack_range = 5;

var player;
var ani_player;

func _ready():
	player = get_tree().root.get_node("Node3D/CharacterBody3D");
	ani_player= $AnimationPlayer
	
func _physics_process(delta):
	var distance_to_player = global_transform.origin.distance_to(player.global_transform.origin);
	if distance_to_player <= attack_range:
		attack();
		
	var direction = (player.global_transform.origin - global_transform.origin).normalized();
	basis.looking_at(direction);
	velocity = direction * speed;
	move_and_slide();
	
func attack():
	pass;
	
func take_damage(damage):
	health -= damage;
	if health <= 0:
		die();
		return;
	ani_player.play("damage_taken");

func die():
	queue_free();
	
