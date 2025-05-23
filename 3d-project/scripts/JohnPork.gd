extends CharacterBody3D;

signal enemy_death

@export var speed = 4;
@export var flee_speed = 10;
@export var health = 20;
@export var turn_speed = 4;

@onready var player = get_tree().root.get_node("Node3D/Player")
@onready var nav_agent = $NavigationAgent3D
@onready var attack_area = $Area3D
@onready var ani_player = $AnimationPlayer;
@onready var mesh = $MeshInstance3D
@onready var porkie_particles = $porkie_particle/GPUParticles3D;
@onready var hit_sounds = [$HitSound1, $HitSound2, $HitSound3]
@onready var death_sound = $DeathSound
@onready var curve = get_tree().get_first_node_in_group("path").curve;
@onready var flee_location = get_flee_point()

@onready var drop_scene = preload("res://assets/Ammo.tscn")

var willdrop = false

func _ready():
	var number1 = randf()
	if number1 <= 0.15:
		willdrop = true
		

func _physics_process(delta):
	var current_location = global_transform.origin;
	var player_location = player.global_transform.origin
	var john_speed
	var target_position;
	
	if player_location.y > 10: 
		john_speed = flee_speed
		target_position = flee_location
	else:
		john_speed = speed
		target_position = player_location
	
	var target_rotation = Vector3(target_position.x, position.y, target_position.z)
	var new_transform = transform.looking_at(target_rotation, Vector3.UP)
	new_transform.basis = new_transform.basis.rotated(Vector3.UP, deg_to_rad(90))
	transform = transform.interpolate_with(new_transform, turn_speed * delta)
	
	if nav_agent.target_position != target_position:
		nav_agent.target_position = target_position
	var next_location = nav_agent.get_next_path_position();
	var target_velocity = (next_location - current_location).normalized() * john_speed
	nav_agent.set_velocity(target_velocity)
	
	if current_location.distance_to(player_location) <= 2:
		ani_player.play("attack")
	
func get_flee_point():
	var length = curve.get_baked_length()
	var distance = randf_range(0, length)
	var point = curve.sample_baked(distance)
	return point
	
func take_damage(damage, from_sniper = false):
	health -= damage;
	if from_sniper:
		var pushback_dir = global_basis.x.normalized()
		position -= pushback_dir * 10
	if health <= 0:
		death_sound.play()
		emit_signal("enemy_death")
		die();
	else:
		var random_hit_sound = randi_range(0, 2)
		hit_sounds[random_hit_sound].play()
		var material = mesh.get_surface_override_material(0).duplicate()
		mesh.set_surface_override_material(0, material)
		var og_color = material.albedo_color
		material.albedo_color = Color.RED
		await get_tree().create_timer(0.1).timeout
		material.albedo_color = og_color

func die():
	porkie_particles.restart()
	porkie_particles.emitting = true
	
	# Detach the particles from the enemy so they don't get deleted with it
	var particles_parent = get_tree().root
	porkie_particles.reparent(particles_parent)
	death_sound.reparent(particles_parent)
	
	# Set the particles to auto-free when they finish
	porkie_particles.finished.connect(porkie_particles.queue_free)
	death_sound.finished.connect(death_sound.queue_free)
	if willdrop:
		drop()
	queue_free()
	
func _on_area_3d_body_entered(body: Node3D) -> void:
	if body == player:
		player.take_damage(10)

func _on_player_reached() -> void:
	if player.global_transform.origin.y > 10:
		flee_location = get_flee_point()

func _on_navigation_agent_3d_velocity_computed(safe_velocity: Vector3) -> void:
	velocity = velocity.move_toward(safe_velocity, 0.1)
	move_and_slide()

func drop():
	var dropinst = drop_scene.instantiate()
	dropinst.global_position = global_position
	get_parent().add_child(dropinst)
	pass
