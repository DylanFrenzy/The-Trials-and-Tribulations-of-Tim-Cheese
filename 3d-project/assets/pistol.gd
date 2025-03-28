extends Node3D

@export var damage := 10
@export var max_ammo := 10
@export var current_ammo := 10
@export var reload_time := 2.0

var is_reloading := false

func _ready():
    $AnimationPlayer.play("idle")

func shoot():
    if is_reloading or current_ammo <= 0:
        return
    
    current_ammo -= 1
    $AnimationPlayer.stop()
    if current_ammo != 0:
        $AnimationPlayer.play("shoot")
    # Play sound, muzzle flash, etc.
    
    # Raycast shooting would be handled by the player script

func reload():
    if is_reloading or current_ammo == max_ammo:
        return
    
    is_reloading = true
    $AnimationPlayer.play("reload")
    await $AnimationPlayer.animation_finished
    current_ammo = max_ammo
    is_reloading = false