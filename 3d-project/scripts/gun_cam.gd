extends Camera3D

var gun;

func _ready() -> void:
	get_active_gun()

func get_active_gun():
	gun = get_node("Weapon Holder").get_child(0)

func _process(delta):
	gun.position.x = lerp(gun.position.x, 0.204, delta * 5)
	gun.position.y = lerp(gun.position.y, -0.17, delta * 5)

func sway(sway_amount):
	gun.position.x -= sway_amount.x * 0.0002
	gun.position.y += sway_amount.y * 0.0002
