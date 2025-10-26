extends RigidBody3D

@export var size := 0.4
@export var splash_radius = 2.0
@export var color := Color.BLACK

@onready var mesh_instance: MeshInstance3D = $MeshInstance3D
@onready var collision_shape: CollisionShape3D = $CollisionShape3D


func _ready():
	mesh_instance.mesh.height = size
	mesh_instance.mesh.radius = size / 2.0
	var material: StandardMaterial3D = mesh_instance.get_surface_override_material(0)
	material.albedo_color = color;
	
	collision_shape.shape.radius = size / 2.0

#func _on_body_entered(body: Node) -> void:
	#var pos = position + (linear_velocity.normalized() * size / 2.0)
	#if body is PaintablePlane:
		#
		#_splash_paint(pos)
		#queue_free()
		##(body as PaintablePlane).paint_world_point(pos, 20.0, color)

func _integrate_forces(state):
	for i in range(state.get_contact_count()):
		var contact_point = state.get_contact_local_position(i)
		var collider = state.get_contact_collider_object(i)
		
		if collider:
			_splash_paint(contact_point)
			queue_free()

func _splash_paint(center: Vector3):
	var space_state = get_world_3d().direct_space_state

	# Create a spherical shape to check within
	var shape = SphereShape3D.new()
	shape.radius = splash_radius

	# Set up query params
	var params = PhysicsShapeQueryParameters3D.new()
	params.shape = shape
	params.transform = Transform3D(Basis(), center)
	params.collide_with_areas = false
	params.collide_with_bodies = true

	# Perform the intersection
	var results = space_state.intersect_shape(params, 32)  # max 32 hits

	for result in results:
		var body = result.collider
		if !body:
			continue
		if body is PaintablePlane:
			body.paint_world_point(center, splash_radius, color)
