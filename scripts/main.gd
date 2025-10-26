extends Node

# TODO autofire, paint fire rate / size modifiers
# TODO investigate enemies getting stuck
# TODO limit spawned enemy count
# TODO start tutorial info
# TODO increasing maze size + saving best score per size
# TODO exit button model
# TODO sound effects (footsteps, exit ping, enemy noises)
# TODO optimize drawing larger circles if necessary
# TODO only activate exit button once painted over
# TODO don't paint backward facing walls
# TODO custom boot screen
# TODO lower res rendering
# TODO menus flair
# TODO loading screen

const MAZE_GENERATOR = preload("uid://dnll2ejxt2cip")

@onready var pause_screen: ColorRect = $Interface/PauseScreen
@onready var title_screen: ColorRect = $Interface/TitleScreen
@onready var end_screen: ColorRect = $Interface/EndScreen

var maze_generator: MazeGenerator

var segment_start_time = 0.0
var level_time := 0.0

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
	segment_start_time = Time.get_ticks_msec()

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
	level_time += Time.get_ticks_msec() - segment_start_time
	get_tree().paused = true
	pause_screen.show()

func _on_resume_event():
	segment_start_time = Time.get_ticks_msec()
	pause_screen.hide()
	get_tree().paused = false

func _on_game_end_event():
	level_time += Time.get_ticks_msec() - segment_start_time
	end_screen.find_child("ScoreLabel").text = "Time: " + str(level_time / 1000.0) + "s"
	get_tree().paused = true
	end_screen.show()
	
