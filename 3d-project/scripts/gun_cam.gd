extends Camera3D

@onready var Node_3D = $Node3D
var zoomed = false

func _process(delta):
	if zoomed: return
	Node_3D.position.x = lerp(Node_3D.position.x, 0.204, delta * 5)
	Node_3D.position.y = lerp(Node_3D.position.y, -0.17, delta * 5)

func sway(sway_amount):
	if zoomed: return
	Node_3D.position.x -= sway_amount.x * 0.0002
	Node_3D.position.y += sway_amount.y * 0.0002
