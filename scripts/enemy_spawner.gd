extends Node3D

const ENEMY = preload("uid://drsgc5ysv3lje")

const MAX_HEIGHT = 4.0
const SPAWN_INTERVAL = 5.0

var splat_positions: Array[Vector3] = []
var painted_amount = 0
var spawn_interval = 20.0
var time_since_spawn = 0.0

func _ready() -> void:
	Global.subscribe("PAINT_SPLASH", _on_splat_event)
	
func _exit_tree() -> void:
	Global.unsubscribe("PAINT_SPLASH", _on_splat_event)

func _physics_process(delta: float) -> void:
	time_since_spawn += delta
	if time_since_spawn >= spawn_interval:
		spawn_enemy()
		time_since_spawn = 0

func _on_splat_event(center: Vector3, splash_radius: float, color: Color):
	if color == Color.BLACK && center.y < MAX_HEIGHT:
		splat_positions.append(center)
		painted_amount += splash_radius
		calculate_spawn_interval()
		print(painted_amount)
		print(spawn_interval)

func calculate_spawn_interval():
	spawn_interval = 20.0 - (min(painted_amount, 200.0) / 200.0) * 15.0

func spawn_enemy() -> void:
	if splat_positions.size() == 0:
		return
	var spawn_pos = splat_positions[randi() % splat_positions.size()]
	var enemy = ENEMY.instantiate()
	enemy.position = Vector3(spawn_pos.x, spawn_pos.y - 2, spawn_pos.z)
	add_child(enemy)
