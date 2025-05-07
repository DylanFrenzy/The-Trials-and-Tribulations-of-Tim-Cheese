extends CharacterBody3D;

signal enemy_death

@export var speed = 4;
@export var health = 20;
@export var turn_speed = 4;

@onready var player = get_tree().root.get_node("Node3D/Player");;
@onready var nav_agent = $NavigationAgent3D
@onready var attack_area = $Area3D
@onready var ani_player = $AnimationPlayer;
@onready var mesh = $MeshInstance3D
@onready var porkie_particles = $porkie_particle/GPUParticles3D;
@onready var hit_sounds = [$HitSound1, $HitSound2, $HitSound3]
@onready var death_sound = $DeathSound

func _physics_process(delta):
	var current_location = global_transform.origin;
	var player_location = player.global_transform.origin
	
	var target_rotation = Vector3(player_location.x, position.y, player_location.z)
	var new_transform = transform.looking_at(target_rotation, Vector3.UP)
	new_transform.basis = new_transform.basis.rotated(Vector3.UP, deg_to_rad(90))
	transform = transform.interpolate_with(new_transform, turn_speed * delta)
	
	nav_agent.target_position = player_location 
	var next_location = nav_agent.get_next_path_position();
	var target_velocity = (next_location - current_location).normalized() * speed
	nav_agent.set_velocity(target_velocity)
	
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
	queue_free()
	
func _on_area_3d_body_entered(body: Node3D) -> void:
	if body == player:
		player.take_damage(10)

func _on_player_reached() -> void:
	ani_player.play("attack");

func _on_navigation_agent_3d_velocity_computed(safe_velocity: Vector3) -> void:
	velocity = velocity.move_toward(safe_velocity, 0.1)
	move_and_slide()
