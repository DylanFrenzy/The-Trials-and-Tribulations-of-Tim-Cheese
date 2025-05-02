extends Node3D

@export var damage := 10
@export var max_ammo := 10
@export var current_ammo := 10

@onready var ani_player = $AnimationPlayer2;
@onready var muzzle_flash = $muzzle_flash
@onready var ray_caster = get_parent().get_parent().get_node("RayCast3D");
@onready var ammo_display = get_tree().root.get_node("Node3D/hud/Ammo")

func _ready():
	$AnimationPlayer.play("idle")
	update_ammo_display(current_ammo)
	
func _input(event):
	if ani_player.is_playing(): return
	
	if (event.is_action_pressed("shoot")):
		if current_ammo != 0:
			current_ammo -= 1;
			update_ammo_display(current_ammo)
			ani_player.play("Fire")
			muzzle_flash.emitting = true
			if ray_caster.is_colliding():
				var target = ray_caster.get_collider();
				if target.has_method("take_damage"):
					target.take_damage(damage);

	if (event.is_action_pressed("reload")):
		muzzle_flash.emitting = false
		if current_ammo == max_ammo: return
		ani_player.play("Reload")
		await ani_player.animation_finished
		current_ammo = max_ammo
		update_ammo_display(max_ammo)
		
func update_ammo_display(ammo):
	ammo_display.text = str(ammo) + "/" + str(max_ammo)
	
