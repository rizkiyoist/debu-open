extends Control

signal back_pressed(origin: String)
signal drive_pressed(origin: String)

func _on_back_pressed() -> void:
	back_pressed.emit("mode_select")

func _on_drive_pressed() -> void:
	drive_pressed.emit("mode_select")
