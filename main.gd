extends Node

# TODO ghost enemy
# TODO enemy spawning mechanics
# TODO start tutorial info
# TODO button model
# TODO paint fire rate / size modifiers
# TODO increasing maze size
# TODO sound effects (footsteps, exit ping, enemy noises)
# TODO optimize drawing larger circles if necessary
# TODO only activate exit button once painted over
# TODO don't paint backward facing walls

const MAZE_GENERATOR = preload("uid://dnll2ejxt2cip")

@onready var pause_screen: ColorRect = $Interface/PauseScreen
@onready var title_screen: ColorRect = $Interface/TitleScreen
@onready var end_screen: ColorRect = $Interface/EndScreen

var maze_generator: MazeGenerator

func _ready() -> void:
	Global.subscribe("GAME_PAUSE", _on_pause_event)
	Global.subscribe("GAME_RESUME", _on_resume_event)
	Global.subscribe("GAME_END", _on_game_end_event)


func start():
	maze_generator = MAZE_GENERATOR.instantiate()
	add_child(maze_generator)
	move_child(maze_generator, 0)
	maze_generator.create(7, 7)
	title_screen.hide()

func _on_start_game_pressed() -> void:
	start()

func _on_resume_button_pressed() -> void:
	Global.emit_event("GAME_RESUME")

func _on_title_button_pressed() -> void:
	title_screen.show()
	pause_screen.hide()
	end_screen.hide()
	get_tree().paused = false
	maze_generator.queue_free()

func _on_pause_event():
	get_tree().paused = true
	pause_screen.show()

func _on_resume_event():
	pause_screen.hide()
	get_tree().paused = false

func _on_game_end_event():
	get_tree().paused = true
	end_screen.show()
