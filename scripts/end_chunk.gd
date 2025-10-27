extends Node3D

@onready var ray_cast_3d: RayCast3D = $RayCast3D
@onready var exit_button: Area3D = $ExitButton
@onready var animation_player: AnimationPlayer = $AnimationPlayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func _physics_process(_delta: float) -> void:
	if ray_cast_3d && ray_cast_3d.is_colliding():
		var collider = ray_cast_3d.get_collider()
		if collider is PaintablePlane:
			collider.reparent(exit_button, true)
			ray_cast_3d.queue_free()

func _on_exit_button_body_entered(body: Node3D) -> void:
	if body is Player:
		animation_player.play("exit_door_slide")

func _on_exit_zone_body_entered(body: Node3D) -> void:
	if body is Player:
		Global.emit_event("GAME_END")
