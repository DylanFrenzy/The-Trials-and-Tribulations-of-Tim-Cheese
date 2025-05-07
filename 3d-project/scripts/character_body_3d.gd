extends CharacterBody3D

signal player_death

@export var mouse_sensitivity := 0.1
@export var move_speed := 5.0
@export var jump_velocity := 4.5
@export var health = 200

@onready var camera := $Camera3D
@onready var GunCam = $Camera3D/SubViewportContainer/SubViewport/GunCam
@onready var AnimationPlayer2 = GunCam.get_node("Pistol2/AnimationPlayer2")
@onready var health_bar = get_parent().get_node("hud/HealthBar")
@onready var hit_sounds = $HitSounds

const  HEADBOB_MOVE_AMOUT = 0.06;
const  HEADBOB_FREQUENCY = 2.4;
var headbobTime = 0.0;

var sniper_knockback_strength = 50;
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

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	$Camera3D/SubViewportContainer/SubViewport.size = DisplayServer.window_get_size()
	health_bar.value = health;

func _input(event):
	if event is InputEventMouseMotion:
		rotate_y(deg_to_rad(-event.relative.x * mouse_sensitivity))
		camera.rotate_x(deg_to_rad(-event.relative.y * mouse_sensitivity))
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-90), deg_to_rad(90))
		GunCam.sway(Vector2(event.relative.x, event.relative.y))

func _physics_process(delta):
	if sniper_knockback_timer > 0:
		sniper_knockbar_dir = camera.global_basis.z.normalized()
		velocity = sniper_knockbar_dir * sniper_knockback_strength
		sniper_knockback_timer -= delta
		move_and_slide()
		return
	print(velocity.y)
	sniper_knockbar_dir = Vector3.ZERO
	GunCam.global_transform = camera.global_transform

	if not is_on_floor():
		velocity.y -= gravity * delta
	
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity
	
	var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if direction:
		velocity.x = direction.x * move_speed
		velocity.z = direction.z * move_speed
	else:
		velocity.x = move_toward(velocity.x, 0, move_speed)
		velocity.z = move_toward(velocity.z, 0, move_speed)
	headbob_effect(delta)
	
	move_and_slide()
	
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
