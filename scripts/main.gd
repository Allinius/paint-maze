extends Node

# autofire, paint fire rate / size modifiers
# limit spawned enemy count
# increasing maze size + saving best score per size
# exit button model
# sound effects (footsteps, paint, enemy noises)
# start tutorial info
# optimize drawing larger circles if necessary
# title screen
# only activate exit button once painted over
# custom boot screen
# loading screen

# add level 7 secret
# adjust explosions
# prevent ghosts spawning on top of player
# TODO making white off-white
# TODO try irregular shapes
# TODO save progress

const MAZE_GENERATOR = preload("uid://dnll2ejxt2cip")
const LEVEL_BUTTON = preload("uid://csmltqkxrnkx7")

@onready var pause_screen: ColorRect = $Interface/PauseScreen
@onready var title_screen: ColorRect = $Interface/TitleScreen
@onready var end_screen: ColorRect = $Interface/EndScreen
@onready var level_screen: ColorRect = $Interface/LevelScreen
@onready var loading_screen: ColorRect = $Interface/LoadingScreen

var maze_generator: MazeGenerator

var segment_start_time = 0.0
var level_time := 0.0

func _ready() -> void:
	Global.subscribe("GAME_PAUSE", _on_pause_event)
	Global.subscribe("GAME_RESUME", _on_resume_event)
	Global.subscribe("GAME_END", _on_game_end_event)


func start(level: int):
	loading_screen.show()
	await get_tree().create_timer(0.05).timeout
	
	Global.current_level = level
	maze_generator = MAZE_GENERATOR.instantiate()
	add_child(maze_generator)
	move_child(maze_generator, 0)
	
	maze_generator.create(Global.level_sizes[level], Global.level_sizes[level])
	
	title_screen.hide()
	level_screen.hide()
	loading_screen.hide()
	level_time = 0.0
	segment_start_time = Time.get_ticks_msec()

func _on_start_game_pressed() -> void:
	if Global.level_scores.size() == 0:
		start(0)
	else:
		update_level_screen()
		level_screen.show()

func _on_resume_button_pressed() -> void:
	Global.emit_event("GAME_RESUME")


func _on_next_level_button_pressed() -> void:
	end_screen.hide()
	get_tree().paused = false
	maze_generator.queue_free()
	start(Global.current_level + 1)

func _on_title_button_pressed() -> void:
	title_screen.show()
	pause_screen.hide()
	end_screen.hide()
	get_tree().paused = false
	maze_generator.queue_free()
	Global.current_level = -1

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
	Global.update_score(Global.current_level, level_time)

	if Global.current_level < Global.level_sizes.size() - 1:
		# last level
		end_screen.find_child("CongratsLabel").text = "You made it out!"
		end_screen.find_child("NextLevelButton").show()
	else:
		end_screen.find_child("CongratsLabel").text = "That's all for now, thanks for playing!"
		end_screen.find_child("NextLevelButton").hide()

	end_screen.show()
	get_tree().paused = true

func update_level_screen():
	var buttons_container := level_screen.get_child(0).get_child(1)
	var existing_buttons = buttons_container.get_children()
	for button in existing_buttons:
		button.queue_free()
	
	for level in range(min(Global.level_sizes.size(), Global.level_scores.size() + 1)):
		var button: Button = LEVEL_BUTTON.instantiate()
		button.text = "Size " + str(level + 1)
		var time_label = button.get_child(0)
		time_label.text = ""
		if Global.level_scores.size() > level:
			time_label.text = str(Global.level_scores[level] / 1000) + "s"
		button.pressed.connect(start.bind(level))
		buttons_container.add_child(button)
