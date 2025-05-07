extends Node3D

@onready var player = get_tree().get_first_node_in_group("player")
@onready var sniper = get_tree().get_first_node_in_group("SNIPAAAAA")


func _on_area_3d_body_entered(body):
    if body == player:
        if sniper.spare_ammo_cap == sniper.current_spare_ammo: return
        sniper.current_spare_ammo = min(sniper.current_spare_ammo + 5, sniper.spare_ammo_cap)
        queue_free()