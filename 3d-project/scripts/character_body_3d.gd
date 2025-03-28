extends CharacterBody3D

signal player_death

@export var mouse_sensitivity := 0.1
@export var move_speed := 5.0
@export var jump_velocity := 4.5
@export var health = 20

@onready var camera := $Camera3D
@onready var GunCam = $Camera3D/SubViewportContainer/SubViewport/GunCam
@onready var AnimationPlayer2 = GunCam.get_node("Pistol2/AnimationPlayer2")
@onready var health_bar = get_parent().get_node("hud/HealthBar")

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var zoomed = false

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
	
	if event.is_action_pressed("zoom"):
		Zoom()
	if event.is_action_released("zoom"):
		Zoom()

func Zoom():
	if !zoomed:
		AnimationPlayer2.play("Zoom")
	else: AnimationPlayer2.play_backwards("Zoom")

	zoomed = !zoomed

func _physics_process(delta):
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
	
	move_and_slide()
	
func take_damage(amount):
	health = max(health - amount, 0)
	health -= amount
	health_bar.value = health
	if (health <= 0):
		die()
		
func die():
	queue_free() 
	emit_signal("player_death")
