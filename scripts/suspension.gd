extends RayCast3D
class_name Suspension

@export var strength = 100000
@export var strength_curve : Curve
@export var damping = 2000
@export var length = 0.4
@export var wheel_radius: float = 0.4
@export var is_drive = false
@export var sc_susp : ShapeCast3D
@export var sc_manual_offset = 0

@onready var wheel: Node3D = get_child(0)

func _ready() -> void:
	target_position.y = -length
	if sc_susp:
		sc_susp.target_position.y = sc_manual_offset
		sc_susp.add_exception(get_parent())

func get_force_vector(rb: RigidBody3D) -> Vector3:
	if is_colliding() or sc_susp.is_colliding():		
		target_position.y = -length
		var contact : Vector3
		if sc_susp:
			# for now it only works with 1 max result, find why later
			var total_contacts : Vector3
			for r in range(sc_susp.max_results):
				total_contacts = total_contacts + sc_susp.get_collision_point(r)
			contact = total_contacts / sc_susp.max_results
		else:
			print("using raycast")
			contact = get_collision_point()
			
		#var current_length := global_position.distance_to(contact)
		var contact_local : Vector3 = to_local(contact)
		var current_length : float = absf(contact_local.y)
		var offset = length - current_length
		
		var up_dir := global_basis.y
		var velocity = helper.get_point_velocity(contact, rb)
		var relative_vel := up_dir.dot(velocity)
		
		var offset_multiplier = strength_curve.sample_baked(offset)
		

		var impact_damping = damping
		
		#handle impact velocity but this feels weirdly dampy
		#var compression_ratio: float = offset / length
		#var impact_damping = damping * (1.0 + compression_ratio * 10.0)
		
		var force_vector = ((strength * offset * offset_multiplier) - (impact_damping * relative_vel)) * up_dir
		
		# wheel position
		wheel.position.y = -(current_length - wheel_radius)
		
		#DebugDraw3D.draw_sphere(contact, 0.15)
		return force_vector
	return Vector3.ZERO
