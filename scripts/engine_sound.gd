extends Node

var is_playing: bool
var hold_counter: float = 0.0
var is_holding_up: bool = false
var is_holding_down: bool = false

const min_hold_time: float = 1.0
const pitch_min = 0.4
const pitch_max = 4.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$AudioStreamPlayer.pitch_scale = pitch_min
	$AudioStreamPlayer.play()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if is_holding_up or is_holding_down:
		if is_holding_up:
			print(hold_counter)
			hold_counter += delta
			if hold_counter > min_hold_time:
				up_pitch(delta)

		if is_holding_down:
			hold_counter += delta
			if hold_counter > min_hold_time:
				down_pitch(delta)
	else:
		hold_counter = 0
			

func up_pitch(delta: float) -> void:
	if $AudioStreamPlayer.pitch_scale < pitch_max:
		$AudioStreamPlayer.pitch_scale = $AudioStreamPlayer.pitch_scale + delta

func down_pitch(delta: float) -> void:
	if $AudioStreamPlayer.pitch_scale > pitch_min:
		$AudioStreamPlayer.pitch_scale = $AudioStreamPlayer.pitch_scale - delta

func set_pitch(speed: float) -> void:
	if $AudioStreamPlayer.pitch_scale > pitch_min && $AudioStreamPlayer.pitch_scale < pitch_max:
		$AudioStreamPlayer.pitch_scale = speed
