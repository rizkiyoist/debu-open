extends Control

signal back_pressed(origin: String)

func _on_back_pressed() -> void:
	back_pressed.emit("mode_select")
