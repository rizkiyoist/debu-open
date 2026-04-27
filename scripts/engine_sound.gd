extends Node

var is_playing: bool
var hold_counter: float = 0.0
var is_holding_up: bool = false
var is_holding_down: bool = false

const min_hold_time: float = 1.0
const pitch_min = 1.0
const pitch_max = 8.0
const BUS_NAME  = "Pitch"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$AudioStreamPlayer.pitch_scale = pitch_min

	var audio_count = $AudioStreamPlayer.max_polyphony
	var timing: float = (1000.0/8) / audio_count
	for i in range($AudioStreamPlayer.max_polyphony):
			await get_tree().create_timer(timing/1000).timeout
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

func set_pitch(pitch: float) -> void:
	if pitch > pitch_min && pitch < pitch_max:
		$AudioStreamPlayer.pitch_scale = pitch
		#var bus_idx = AudioServer.get_bus_index(BUS_NAME)
		#var pitch_effect = AudioServer.get_bus_effect(bus_idx, 0)
		#pitch_effect.pitch_scale = 1.0 / pitch
		#$AudioStreamPlayer.bus = BUS_NAME
