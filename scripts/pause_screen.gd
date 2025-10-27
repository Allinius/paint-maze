extends ColorRect


var bus_index: int
@onready var volume_slider: HSlider = $VBoxContainer/VolumeSlider

func _ready():
	bus_index = AudioServer.get_bus_index("Master")
	
	volume_slider.value = db_to_linear(AudioServer.get_bus_volume_db(bus_index))

func _unhandled_input(event: InputEvent) -> void:
	if visible && event.is_action_pressed("ui_cancel"):
		Global.emit_event("GAME_RESUME")
		get_viewport().set_input_as_handled()


func _on_sensitivity_slider_value_changed(value: float) -> void:
	Global.look_sensitivity = value


func _on_volume_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(bus_index, linear_to_db(value))
