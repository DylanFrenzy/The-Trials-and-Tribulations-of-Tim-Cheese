extends Node3D

@onready var pistol = $Pistol
@onready var sniper = $SniperRifle
@onready var pistol_ani = $Pistol/AnimationPlayer2
@onready var sniper_ani = $SniperRifle/AnimationPlayer2

func _ready() -> void:
	remove_child(sniper);
	
func _input(event: InputEvent) -> void:
	if (event.is_action_pressed("pistol_switch")):
		if has_node("Pistol") || sniper_ani.is_playing() || sniper.zoomed: return
		swap_to_pistol()
		
	if (event.is_action_pressed("sniper_switch")):
		if has_node("SniperRifle") || pistol_ani.is_playing(): return
		swap_to_sniper()
	
	if (event.is_action_pressed("change_weapon_scroll")):
		if pistol_ani.is_playing() || sniper_ani.is_playing(): return
		if (has_node("Pistol")): swap_to_sniper()
		else: swap_to_pistol()
		pass
		
func swap_to_pistol():
	remove_child(sniper)
	add_child(pistol)
	pistol.update_ammo_display(pistol.current_ammo)
	
func swap_to_sniper():
	remove_child(pistol)
	add_child(sniper)
	sniper.update_ammo_display(sniper.current_ammo)
