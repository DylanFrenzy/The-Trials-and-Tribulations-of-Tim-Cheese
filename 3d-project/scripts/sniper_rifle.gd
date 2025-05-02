extends Node3D

@export var damage := 20
@export var max_ammo := 5
@export var current_ammo := 5

@onready var ani_player = $AnimationPlayer2
#@onready var muzzle_flash = $muzzle_flash
@onready var ray_caster = get_parent().get_parent().get_node("RayCast3D");
@onready var ammo_display = get_tree().root.get_node("Node3D/hud/Ammo")
@onready var gun_cam = get_parent().get_parent()
var is_reloading := false
var zoomed = false
var shooting := false

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("zoom"):
		if shooting or is_reloading:
			await ani_player.animation_finished
		Zoom()

	if event.is_action_released("zoom"):
		if shooting or is_reloading:
			await ani_player.animation_finished
		Zoom()
		
		
	if (event.is_action_pressed("shoot")) and !shooting:
		if ani_player.is_playing() and !zoomed: return
		if current_ammo != 0:
			current_ammo -= 1;
			update_ammo_display(current_ammo)
			if !zoomed:
				ani_player.play("shoot")
				shooting = true
				if ray_caster.is_colliding():
					var target = ray_caster.get_collider();
					if target.has_method("take_damage"):
						target.take_damage(damage);
				await ani_player.animation_finished
				shooting = false
			else:
				ani_player.play("Zoom_Fire")
				shooting = true
				if ray_caster.is_colliding():
					var target = ray_caster.get_collider();
					if target.has_method("take_damage"):
						target.take_damage(damage);
				await ani_player.animation_finished
				shooting = false

			#muzzle_flash.emitting = true
			#if ray_caster.is_colliding():
				#var target = ray_caster.get_collider();
				#if target.has_method("take_damage"):
					#target.take_damage(damage);
	
	if (event.is_action_pressed("reload")):
		#muzzle_flash.emitting = false
		if ani_player.is_playing() || is_reloading || current_ammo == max_ammo: return
		if zoomed:
			ani_player.play_backwards("Zoom")
			await ani_player.animation_finished
		is_reloading = true
		ani_player.play("Reload")
		await ani_player.animation_finished
		current_ammo = max_ammo
		update_ammo_display(max_ammo)
		is_reloading = false

func Zoom():
	if !zoomed:
		ani_player.play("Zoom")
	else: ani_player.play_backwards("Zoom")
	zoomed = !zoomed
	gun_cam.zoomed = zoomed
	
func update_ammo_display(ammo):
	ammo_display.text = str(ammo) + "/" + str(max_ammo)
