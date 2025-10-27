extends Node3D

const FLUP = preload("uid://b0ftee47g5hkd")

func _ready() -> void:
	Global.subscribe("PAINT_SPLASH", _on_paint_splash)

func _exit_tree() -> void:
	Global.unsubscribe("PAINT_SPLASH", _on_paint_splash)

#func _on_paint_splash(center: Vector3, _splash_radius: float, _color: Color):
	#var audioplayer = AudioStreamPlayer3D.new()
	#audioplayer.global_position = center
	#audioplayer.stream = SPLAT
	#add_child(audioplayer)
	
func _on_paint_splash(center: Vector3, splash_radius: float, _color: Color):
	if !FLUP:
		return

	# Create a temporary AudioStreamPlayer3D
	var player := AudioStreamPlayer3D.new()
	player.stream = FLUP
	player.transform.origin = center
	player.unit_size = splash_radius * 4
	player.volume_db = randf_range(10.0, 14.0)  # small random volume variation
	player.pitch_scale = randf_range(0.8, 1.2)  # random pitch for variety
	player.autoplay = false

	add_child(player)
	player.play()

	# Queue free after sound finishes
	var duration = player.stream.get_length() / player.pitch_scale
	get_tree().create_timer(duration).connect("timeout", Callable(player, "queue_free"))
