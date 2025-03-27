extends MeshInstance3D
@export var speed = 10
@export var rot_speed = 10

func _ready() -> void:
	pass
	
func _process(delta: float) -> void:
	position.x += delta * speed
	position.z += delta * speed
	pass
