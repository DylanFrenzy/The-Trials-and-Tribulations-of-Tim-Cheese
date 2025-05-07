extends Node3D

@onready var player = get_tree().get_first_node_in_group("player")
@onready var arms = get_tree().get_first_node_in_group("arms")


func _on_area_3d_body_entered(body):
	if body == player:
		if arms.update_spare_ammo():
			queue_free()
