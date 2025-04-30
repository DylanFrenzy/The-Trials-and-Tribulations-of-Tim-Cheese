extends Gun

var zoomed = false;

func _init():
	damage = 20
	max_ammo = 5
	set_position = Vector3(0.166, -0.188, -0.274)
	
func _input(event: InputEvent) -> void:
	super._input(event);
	if (event.is_action_pressed("zoom")):
		Zoom();
	if (event.is_action_released("zoom")):
		Zoom()

func Zoom():
	#if !zoomed:
	#	ani_player.play("Zoom")
	#else: ani_player.play_backwards("Zoom")

	zoomed = !zoomed
