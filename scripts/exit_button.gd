extends Area3D

@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	Global.subscribe("PAINT_SPLASH", _on_paint_splash)

func _exit_tree() -> void:
	Global.unsubscribe("PAINT_SPLASH", _on_paint_splash)

func _on_paint_splash(center: Vector3, splash_radius: float, color: Color):
	if color != Color.BLACK:
		return
	if !monitoring && center.distance_to(global_position) < splash_radius + 0.7:
		monitoring = true
		animation_player.play("activate_button")
