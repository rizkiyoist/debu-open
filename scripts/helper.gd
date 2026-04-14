extends Node
class_name helper

static func get_point_velocity(point: Vector3, r: RigidBody3D) -> Vector3:
	return r.linear_velocity + r.angular_velocity.cross(point-r.global_position)
