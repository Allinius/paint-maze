extends ColorRect



func _unhandled_input(event: InputEvent) -> void:
	if visible && event.is_action_pressed("ui_cancel"):
		Global.emit_event("GAME_RESUME")
		get_viewport().set_input_as_handled()


func _on_sensitivity_slider_value_changed(value: float) -> void:
	Global.look_sensitivity = value
