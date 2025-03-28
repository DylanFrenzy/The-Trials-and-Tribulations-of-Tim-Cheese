extends Node3D

@export var damage := 10
@export var max_ammo := 10
@export var current_ammo := 10
@export var reload_time := 2.0

@onready var ani_player = $AnimationPlayer2;
@onready var muzzle_flash = $muzzle_flash
@onready var ray_caster = $RayCast3D;
var is_reloading := false

func _ready():
	$AnimationPlayer.play("idle")
	
func _input(event: InputEvent) -> void:
	if (event.is_action_pressed("shoot")):
		if ani_player.is_playing(): return
		if current_ammo != 0:
			current_ammo -= 1;
			ani_player.play("Fire")
			muzzle_flash.emitting = true
			if ray_caster.is_colliding():
				var target = ray_caster.get_collider();
				if target.has_method("take_damage"):
					target.take_damage(10);

	if (event.is_action_pressed("reload")):
		muzzle_flash.emitting = false
		if ani_player.is_playing() || is_reloading || current_ammo == max_ammo: return
		is_reloading = true
		ani_player.play("Reload")
		await ani_player.animation_finished
		current_ammo = max_ammo
		is_reloading = false
	
