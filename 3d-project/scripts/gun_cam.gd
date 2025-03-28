extends Camera3D

@onready var Node_3D = $Node3D
@onready var animation_player = $Node3D/Pistol/AnimationPlayer2
@onready var Muzzle_Flash = $muzzle_flash
@onready var Pistol = $Node3D/Pistol

var current_ammo : int

func _ready():
	current_ammo = Pistol.current_ammo
	pass

func _process(delta):
	Node_3D.position.x = lerp(Node_3D.position.x, 0.204, delta * 5)
	Node_3D.position.y = lerp(Node_3D.position.y, -0.17, delta * 5)
	pass

func sway(sway_amount):
	Node_3D.position.x -= sway_amount.x * 0.0002
	Node_3D.position.y += sway_amount.y * 0.0002

func _input(event: InputEvent) -> void:
	if (event.is_action_pressed("shoot")):
		if animation_player.is_playing(): return
		if current_ammo != 0:
			animation_player.play("Fire")
			Muzzle_Flash.emitting = true
		else: animation_player.stop("Fire")

	if (event.is_action_pressed("reload")):
		if animation_player.is_playing(): return
		animation_player.play("Reload")
		
