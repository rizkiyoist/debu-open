extends Control

signal start_pressed(origin: String)
signal exit_pressed(origin: String)

func _on_start_button_pressed() -> void:
	start_pressed.emit("main_menu")


func _on_exit_button_pressed() -> void:
	exit_pressed.emit("main_menu")
