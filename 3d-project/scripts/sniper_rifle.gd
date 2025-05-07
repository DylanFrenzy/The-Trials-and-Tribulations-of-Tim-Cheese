extends Node3D

@export var damage := 20
@export var max_ammo := 5
@export var current_ammo := 5
@export var spare_ammo_cap := 20

@onready var player = get_tree().get_first_node_in_group("player")
@onready var ani_player = $AnimationPlayer2
@onready var muzzle_flash = $muzzle_flash
@onready var ray_caster = get_parent().get_parent().get_node("RayCast3D");
@onready var ammo_display = get_tree().root.get_node("Node3D/hud/Ammo")
@onready var gun_cam = get_parent().get_parent()
var zoomed = false
var current_spare_ammo = 5

func _input(event: InputEvent) -> void:
	if ani_player.is_playing(): return
		
	if event.is_action_pressed("zoom"):
		Zoom()
		
	if (event.is_action_pressed("shoot")):
		if current_ammo != 0:
			current_ammo -= 1;
			update_ammo_display(current_ammo)
			if !zoomed:
				ani_player.play("shoot")
				muzzle_flash.emitting = true
			else:
				ani_player.play("Zoom_Fire")
				muzzle_flash.emitting = true
			player.sniper_knockback_timer = 0.2
			if ray_caster.is_colliding():
				var target = ray_caster.get_collider();
				if target.has_method("take_damage"):
					target.take_damage(damage, true);
	
	if (event.is_action_pressed("reload")):
		muzzle_flash.emitting = false
		if current_ammo == max_ammo or current_spare_ammo == 0:
			return
		ani_player.play("Reload")
		await ani_player.animation_finished
		if current_spare_ammo >= max_ammo - current_ammo:
			current_spare_ammo -= max_ammo - current_ammo
			current_ammo = max_ammo 
		else: 
			current_ammo += current_spare_ammo
			current_spare_ammo = 0


		update_ammo_display(max_ammo)
		if zoomed:
			ani_player.play("Zoom")

func Zoom():
	if !zoomed:
		ani_player.play("Zoom")
	else: ani_player.play_backwards("Zoom")
	zoomed = !zoomed
	gun_cam.zoomed = zoomed
	
func update_ammo_display(ammo):
	ammo_display.text = str(ammo) + "/" + str(max_ammo)
