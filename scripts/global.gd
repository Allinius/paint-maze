extends Node

var look_sensitivity := 0.005
var player: Player
var level_sizes: Array[int] = [7, 9, 13, 17, 21, 25, 31]
var level_scores: Array[float] = []

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

func emit_event(event: String, ...args: Array[Variant]):
	if subscribers.has(event):
		for callback in subscribers[event]:
			callback.callv(args)

func random_direction_3d() -> Vector3:
	var z = randf_range(-1.0, 1.0)
	var theta = randf() * TAU
	var r = sqrt(1.0 - z * z)
	return Vector3(r * cos(theta), r * sin(theta), z)

func update_score(level: int, time: float):
	if level_scores.size() > level:
		if level_scores[level] < time:
			level_scores[level] = time
	else:
		level_scores.append(time)
