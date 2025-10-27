extends Node3D

@onready var ray_cast_3d: RayCast3D = $RayCast3D

var roof_to_destroy: PaintablePlane

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func _physics_process(_delta: float) -> void:
	if ray_cast_3d && ray_cast_3d.is_colliding():
		var collider = ray_cast_3d.get_collider()
		if collider is PaintablePlane:
			roof_to_destroy = collider
			ray_cast_3d.queue_free()


func _on_exit_button_body_entered(body: Node3D) -> void:
	if body is Player:
		roof_to_destroy.queue_free()
