extends RigidBody3D
class_name Car

@export var susps: Array[Suspension]
@export var throttle_force = 5000
@export var reverse_force = 2000
@export var brake_force = 3000
@export var max_wheel_speed = 60.0
@export var max_reverse_wheel_speed = 20.0
@export var throttle_curve: Curve
@export var tire_grip_curve: Curve

# maybe move this to susp?
@export var wheel_turn_speed = 4.0 # radian
@export var wheel_max_turn_deg := 15
@export var skid_marks : Array[GPUParticles3D]

var throttle_applied = false
var reverse_applied = false
var is_braking = false
var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
var throttle_wheelspin = 15 # fake more wheelspin on throttle
var throttle_wheelspin_limit = 10.0 # speed at which to stop faking throttle wheelspin
var brake_wheellock = 15 # fake brake locking effect
var susp_detected_max_force : Vector3

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	_process_controls()
	_process_suspension()
	_process_steering_rotation(delta)
		
func _process_suspension() -> void:
	var susp_id = 0
	for susp in susps:
		var susp_force = susp.get_force_vector(self)
		var susp_offset = susp.global_position - global_position
		apply_force(susp_force, susp_offset) # suspension force

		_process_traction(susp, susp_id)
		susp_id += 1
		#DebugDraw3D.draw_arrow_ray(susp.global_position, susp_force/mass, 0.5, Color.RED, 0.1)

func _process_traction(susp: Suspension, susp_id: int) -> void:
	var wheel_forward_dir = -susp.global_basis.z
	var wheel_right_side: Vector3 = susp.global_basis.x
	var wheel_vel = helper.get_point_velocity(susp.global_position, self)
	var sliding_x_speed := wheel_right_side.dot(wheel_vel)
	# TODO: handle possibility of divide by zero
	var lat_grip_factor := absf(sliding_x_speed/wheel_vel.length()) # magniture of slide
	var wheel_speed = wheel_forward_dir.dot(wheel_vel)
	var visual_wheel_speed = wheel_speed
	var susp_force_vector = susp.get_force_vector(self)
	
	
	var lat_grip_multiplier = tire_grip_curve.sample_baked(lat_grip_factor)
	
	skid_marks[susp_id].emitting = false
	
	if susp.is_colliding() or susp.sc_susp.is_colliding():
		# wheel right side * sideway sliding speed * grip multiplier * overcomed force
		#var lateral_force = -wheel_right_side * sliding_x_speed * lat_grip_multiplier * (mass/4) * gravity
		var lateral_force = -wheel_right_side * sliding_x_speed * lat_grip_multiplier * susp_force_vector.y
		
		var force_pos = susp.wheel.global_position - global_position
		apply_force(lateral_force, force_pos)
		#DebugDraw3D.draw_arrow_ray(susp.global_position, lateral_force/mass, 0.5, Color.BLUE, 0.1)
		
		# apply throttle and add wheel rotation
		var susp_offset = susp.global_position - global_position
		if throttle_applied && susp.is_drive:
			var throttle_force_multiplier = throttle_curve.sample_baked(wheel_speed/max_wheel_speed)
			var throttle_force_vector = wheel_forward_dir * throttle_force * throttle_force_multiplier
			apply_force(throttle_force_vector, susp_offset) #engine force
			#DebugDraw3D.draw_arrow_ray(susp.global_position, throttle_force_vector/mass, 0.5, Color.YELLOW, 0.1)
			if visual_wheel_speed < throttle_wheelspin_limit:
				visual_wheel_speed = wheel_speed + throttle_wheelspin
				skid_marks[susp_id].global_position = susp.get_collision_point() + Vector3.UP * 0.05
				skid_marks[susp_id].look_at(skid_marks[susp_id].global_position + global_basis.z)
				skid_marks[susp_id].emitting = true
		
		if reverse_applied && wheel_speed > 0:
			if wheel_speed > brake_wheellock:
				visual_wheel_speed = wheel_speed - brake_wheellock
			else:
				visual_wheel_speed = 0.0
			
			apply_force(susp.global_basis.z * brake_force, susp_offset)
			skid_marks[susp_id].global_position = susp.get_collision_point() + Vector3.UP * 0.1
			skid_marks[susp_id].look_at(skid_marks[susp_id].global_position + global_basis.z)
			skid_marks[susp_id].emitting = true
		
		if reverse_applied && wheel_speed <= 0 && susp.is_drive:
			var reverse_force_multiplier = throttle_curve.sample_baked(-wheel_speed/max_reverse_wheel_speed)
			var reverse_force_vector = -wheel_forward_dir * reverse_force * reverse_force_multiplier
			apply_force(reverse_force_vector, susp_offset)

	# wheel rotation
	susp.wheel.rotate_x(-visual_wheel_speed * get_process_delta_time()/susp.wheel_radius)

	return
	
func _process_steering_rotation(delta: float) -> void:
	var turn_input = Input.get_axis("turn_right","turn_left") * wheel_turn_speed
	if turn_input:
		$SuspFrontLeft.rotation.y = clampf($SuspFrontLeft.rotation.y + turn_input * delta,
		deg_to_rad(-wheel_max_turn_deg), deg_to_rad(wheel_max_turn_deg))
		$SuspFrontRight.rotation.y = clampf($SuspFrontRight.rotation.y + turn_input * delta,
		deg_to_rad(-wheel_max_turn_deg), deg_to_rad(wheel_max_turn_deg))
	else:
		$SuspFrontLeft.rotation.y = move_toward($SuspFrontLeft.rotation.y, 0, wheel_turn_speed*delta)
		$SuspFrontRight.rotation.y = move_toward($SuspFrontRight.rotation.y, 0, wheel_turn_speed*delta)

func _process_controls() -> void:
	if Input.is_action_pressed("throttle"):
		throttle_applied = true
	else:
		throttle_applied = false
	if Input.is_action_pressed("reverse"):
		reverse_applied = true
	else:
		reverse_applied = false
		
