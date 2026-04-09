extends Node

@export var main_menu_packed: PackedScene
@export var mode_select_packed: PackedScene

var selected_level: PackedScene

func _ready() -> void:
	load_main_menu("init")


func load_main_menu(origin: String) -> void:
	var main_menu: Control = main_menu_packed.instantiate()
	
	# cleanup
	var kids: Array[Node] = self.get_children()
	for kid in kids:
		self.remove_child(kid)
	
	self.add_child(main_menu)
	main_menu.start_pressed.connect(load_mode_select)
	
func load_mode_select(origin: String) -> void:
	var mode_select: Control = mode_select_packed.instantiate()
	
	var kids: Array[Node] = self.get_children()
	for kid in kids:
		self.remove_child(kid)
	
	self.add_child(mode_select)
	mode_select.back_pressed.connect(load_main_menu)
