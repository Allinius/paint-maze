extends Node

var look_sensitivity = 0.005 

var subscribers = {}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func subscribe(event: String, callback: Callable) -> void:
	if !subscribers.has(event):
		subscribers[event] = []
	subscribers[event].append(callback)

func emit_event(event: String, ...args):
	if subscribers.has(event):
		for callback in subscribers[event]:
			callback.callv(args)
