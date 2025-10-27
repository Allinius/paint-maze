extends Node3D

const ENEMY = preload("uid://drsgc5ysv3lje")

const MAX_HEIGHT = 3.9
const MAX_ENEMY_COUNT = 10
const MIN_SPAWN_INTERVAL = 5.0
const MAX_SPAWN_INTERVAL = 20.0

var splat_positions: Array[Vector3] = []
var painted_amount = 0
var spawn_interval = 20.0
var time_since_spawn = 0.0
var enemy_count := 0

func _ready() -> void:
	Global.subscribe("PAINT_SPLASH", _on_splat_event)
	Global.subscribe("ENEMY_EXPLODED", _on_enemy_exploded)
	
func _exit_tree() -> void:
	Global.unsubscribe("PAINT_SPLASH", _on_splat_event)
	Global.unsubscribe("ENEMY_EXPLODED", _on_enemy_exploded)

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
		# print(painted_amount)
		# print(spawn_interval)

func calculate_spawn_interval():
	spawn_interval = MAX_SPAWN_INTERVAL - (min(painted_amount, 200.0) / 200.0) * (MAX_SPAWN_INTERVAL - MIN_SPAWN_INTERVAL)
	#spawn_interval = 5.0

func spawn_enemy() -> void:
	if splat_positions.size() == 0 || enemy_count >= MAX_ENEMY_COUNT:
		return
	var spawn_pos = splat_positions[randi() % splat_positions.size()]
	var enemy = ENEMY.instantiate()
	enemy.position = Vector3(spawn_pos.x, spawn_pos.y - 2, spawn_pos.z)
	add_child(enemy)
	enemy_count += 1

func _on_enemy_exploded(..._args: Array):
	enemy_count -= 1
	
