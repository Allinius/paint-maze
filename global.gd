extends Node

var look_sensitivity = 0.005
var player: Player

var subscribers: Dictionary[String, Array] = {}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func subscribe(event: String, callback: Callable) -> void:
	if !subscribers.has(event):
		subscribers[event] = []
	subscribers[event].append(callback)

func unsubscribe(event: String, callback: Callable) -> void:
	if subscribers.has(event):
		subscribers[event].erase(callback)

func emit_event(event: String, ...args):
	if subscribers.has(event):
		for callback in subscribers[event]:
			callback.callv(args)

func random_direction_3d() -> Vector3:
	var z = randf_range(-1.0, 1.0)
	var theta = randf() * TAU
	var r = sqrt(1.0 - z * z)
	return Vector3(r * cos(theta), r * sin(theta), z)
