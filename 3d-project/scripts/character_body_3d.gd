extends CharacterBody3D

signal player_death

@export var mouse_sensitivity := 0.1
@export var move_speed := 7.0
@export var jump_velocity := 6
@export var health = 200
@export var auto_jump = true;

@onready var camera := $Camera3D
@onready var GunCam = $Camera3D/SubViewportContainer/SubViewport/GunCam
@onready var health_bar = get_parent().get_node("hud/HealthBar")
@onready var hit_sounds = $HitSounds

var target_velocity;
var ground_accel = 14.0;
var ground_decel = 10.0
var ground_friction = 6.0
var air_cap = 0.85
var air_accel = 800
var air_move_speed = 500;

const  HEADBOB_MOVE_AMOUT = 0.06;
const  HEADBOB_FREQUENCY = 2.4;
var headbobTime = 0.0;

var sniper_knockback_strength = 20;
var sniper_knockback_timer = 0;
var sniper_knockbar_dir = Vector3.ZERO

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var hit_sound_time_intervals = [
	{
		"from": 9.5,
		"to": 10.5,
	},
	{
		"from": 14.0,
		"to": 15.0,
	},
	{
		"from": 17.3,
		"to": 18.3,
	}
]
#in seconds
func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	$Camera3D/SubViewportContainer/SubViewport.size = DisplayServer.window_get_size()
	health_bar.value = health;

func _input(event):
	if event is InputEventMouseButton:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	elif event.is_action_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		
	if event is InputEventMouseMotion && Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		rotate_y(deg_to_rad(-event.relative.x * mouse_sensitivity))
		camera.rotate_x(deg_to_rad(-event.relative.y * mouse_sensitivity))
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-90), deg_to_rad(90))
		GunCam.sway(Vector2(event.relative.x, event.relative.y))

func _physics_process(delta):
	if global_position.y < -50: die()
	if sniper_knockback_timer > 0:
		sniper_knockbar_dir = camera.global_basis.z.normalized()
		velocity = sniper_knockbar_dir * sniper_knockback_strength
		sniper_knockback_timer -= delta
	else:
		sniper_knockbar_dir = Vector3.ZERO
		GunCam.global_transform = camera.global_transform
	
		var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_back").normalized()
		target_velocity = (global_basis * Vector3(input_dir.x, 0, input_dir.y))
	
		if is_on_floor():
			if Input.is_action_just_pressed("jump") || (auto_jump && Input.is_action_pressed("jump")):
				velocity.y = jump_velocity
			_handle_ground_phyics(delta)
		else:
			_handle_air_physics(delta)

	move_and_slide()
	
func _handle_ground_phyics(delta):
	var current_speed_in_target_velocity = velocity.dot(target_velocity) #.dot checks perpendicularity
	var speed_cap = min((move_speed * target_velocity).length(), move_speed)
	var add_speed_till_cap = speed_cap - current_speed_in_target_velocity;
	if add_speed_till_cap > 0:
		var accel_speed = ground_accel * move_speed * delta
		accel_speed = min(accel_speed, add_speed_till_cap)
		velocity += accel_speed * target_velocity
	
	if (velocity.length() <= 0): return;
	
	var control = max(velocity.length(), ground_decel)
	var drop = control * ground_friction * delta
	var new_speed = max(velocity.length() - drop, 0.0)
	new_speed /= velocity.length()
	velocity *= new_speed
	headbob_effect(delta)
	
func _handle_air_physics(delta):
	velocity.y -= gravity * delta
	var current_speed_in_target_velocity = velocity.dot(target_velocity)
	var speed_cap = min((air_move_speed * target_velocity).length(), air_cap)
	var add_speed_till_cap = speed_cap - current_speed_in_target_velocity
	if add_speed_till_cap > 0:
		var accel_speed = air_move_speed * air_accel * delta
		accel_speed = min(accel_speed, add_speed_till_cap)
		velocity += accel_speed * target_velocity
	
func headbob_effect(delta):
	headbobTime += delta * velocity.length()
	var bob_x = cos(headbobTime * HEADBOB_FREQUENCY * 0.5) * HEADBOB_MOVE_AMOUT
	var bob_y = sin(headbobTime * HEADBOB_FREQUENCY) * HEADBOB_MOVE_AMOUT
	camera.position = Vector3(bob_x, bob_y, 0)
	
func take_damage(amount):
	var ran_num = randi_range(0, 2)
	var sound_interval = hit_sound_time_intervals[ran_num]
	hit_sounds.hit_sound_play(sound_interval["from"], sound_interval["to"])
	health = max(health - amount, 0)
	health_bar.value = health
	if (health <= 0):
		die()
		
func die():
	queue_free() 
	emit_signal("player_death")
