extends Node3D

@onready var ray_cast_3d: RayCast3D = $RayCast3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func _physics_process(_delta: float) -> void:
	if ray_cast_3d && ray_cast_3d.is_colliding():
		var collider = ray_cast_3d.get_collider()
		if collider is PaintablePlane:
			collider.queue_free()
			ray_cast_3d.queue_free()
