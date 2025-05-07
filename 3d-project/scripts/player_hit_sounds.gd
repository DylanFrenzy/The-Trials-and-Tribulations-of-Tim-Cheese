extends AudioStreamPlayer3D

var end;

func _process(_delta: float) -> void:
	if !playing:
		return
	if get_playback_position() > end: stop();

func hit_sound_play(from, to):
	end = to;
	play(from)
