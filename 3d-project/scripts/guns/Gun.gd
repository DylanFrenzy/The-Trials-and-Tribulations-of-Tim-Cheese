extends Node
class_name Gun

@export var damage := 10
@export var max_ammo := 10

@onready var current_ammo = max_ammo
@onready var ani_player = $AnimationPlayer;
@onready var muzzle_flash = $muzzle_flash
@onready var ray_caster = get_parent().get_parent().get_node("RayCast3D");
@onready var ammo_display = get_tree().root.get_node("Node3D/hud/Ammo")
@onready var click_sound = get_parent().get_parent().get_node("AudioStreamPlayer3D5");
@onready var pistol = $Pistol;
@onready var sniper = get_parent().get_node("Sniper Rifle");
var is_reloading := false
var weapon_List = [0, 1];
#var current_Weapon = weapon_List[0];
var current_Weapon = 0

func _ready():
	update_ammo_display(current_ammo)
	
func _input(event):
	if (event.is_action_pressed("shoot")):
		if ani_player.is_playing(): return
		if current_ammo != 0:
			current_ammo -= 1;
			update_ammo_display(current_ammo)
			ani_player.play("Fire")
			muzzle_flash.emitting = true
			if ray_caster.is_colliding():
				var target = ray_caster.get_collider();
				if target.has_method("take_damage"):
					target.take_damage(10);
		else: click_sound.play()

	if (event.is_action_pressed("reload")):
		muzzle_flash.emitting = false
		if ani_player.is_playing() || is_reloading || current_ammo == max_ammo: return
		is_reloading = true
		ani_player.play("reload_2")
		await ani_player.animation_finished
		current_ammo = max_ammo
		update_ammo_display(max_ammo)
		is_reloading = false

	if event.is_action_pressed("swap_weapon"):
		swap_weapon()
		#if ani_player.is_playing(): 
		#	return
		#weapon_List.erase(0)
		#if weapon_List.has (1):
		#	weapon_List.append(0)
		#if weapon_List.has (0):
		#	weapon_List.append(1)
		#$pistol.visible = !$pistol.visible
		#$sniper.visible = !$sniper.visible

func swap_weapon():
	if ani_player.is_playing():
		return
	current_Weapon = (current_Weapon + 1) % weapon_List.size()
	update_weapon_visibility()

func update_weapon_visibility():
	match current_Weapon:
		0:  # Pistol
			pistol.visible = true
			sniper.visible = false
		1:  # Sniper
			pistol.visible = false
			sniper.visible = true

			
		
		pass
		
func update_ammo_display(ammo):
	ammo_display.text = str(ammo) + "/" + str(max_ammo)
