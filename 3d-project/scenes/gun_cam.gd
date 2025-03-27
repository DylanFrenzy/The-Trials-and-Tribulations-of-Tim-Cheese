extends Camera3D

@onready var Node_3D = $Node3D

func _ready():
    pass

func _process(delta):
    Node_3D.position.x = lerp(Node_3D.position.x, 0.204, delta * 5)
    Node_3D.position.y = lerp(Node_3D.position.y, -0.17, delta * 5)
    pass

func sway(sway_amount):
    Node_3D.position.x -= sway_amount.x * 0.0002
    Node_3D.position.y += sway_amount.y * 0.0002

