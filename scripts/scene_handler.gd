extends Node

@export var main_menu_packed: PackedScene
@export var mode_select_packed: PackedScene
@export var proto_game_packed: PackedScene
@export var track1: PackedScene
@export var car1: PackedScene

var selected_level: PackedScene

func _ready() -> void:
	#load_main_menu("init")
	trial_spawn()
	
func trial_spawn() -> void:
	var track: Node3D = track1.instantiate()
	var car: Node3D = car1.instantiate()
	self.add_child(track)
	self.add_child(car)
	


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
	mode_select.drive_pressed.connect(start_game)
	

func start_game(origin: String) -> void:
	var kids: Array[Node] = self.get_children()
	for kid in kids:
		self.remove_child(kid)
	
	print("start")
	var game_scene: Node3D = proto_game_packed.instantiate()
	self.add_child(game_scene)
