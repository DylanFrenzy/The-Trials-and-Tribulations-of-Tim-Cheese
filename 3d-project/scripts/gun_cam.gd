extends Camera3D

@onready var weapon_holder = get_node("Weapon Holder")

func _process(delta):
	weapon_holder.position.x = lerp(weapon_holder.position.x, 0.204, delta * 5)
	weapon_holder.position.y = lerp(weapon_holder.position.y, -0.17, delta * 5)
	pass

func sway(sway_amount):
	weapon_holder.position.x -= sway_amount.x * 0.0002
	weapon_holder.position.y += sway_amount.y * 0.0002
