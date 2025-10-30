class_name Player
extends CharacterBody3D

@onready var head: Node3D = $Head
@onready var camera: Camera3D = $Head/Camera3D
@onready var footstep_sound_player: AudioStreamPlayer3D = $FootstepSoundPlayer
@onready var shot_sound_player: AudioStreamPlayer3D = $ShotSoundPlayer

const PAINT_BLOB = preload("uid://c5ybl7jbx7jpb")
const THROW_FORCE = 13.0
const THROW_ANGLE = 15.0

const SPEED = 5.0
const JUMP_VELOCITY = 4.5

const HIT_BY_PAINT_DISTANCE = 5.0

const MIN_BLOB_SPLASH_RADIUS = 0.5
const MAX_BLOB_SPLASH_RADIUS = 2.0
const MIN_FIRE_INTERVAL = 0.2
const MAX_FIRE_INTERVAL = 1.0
var blob_splash_radius := MIN_BLOB_SPLASH_RADIUS
var fire_interval := MAX_FIRE_INTERVAL
var time_since_last_fired = 100.0

var footstep_interval = 4.0
var time_since_last_footstep = 0.0

var explosion_impulse: Vector3

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	Global.player = self
	Global.subscribe("GAME_RESUME", _capture_mouse)
	Global.subscribe("GAME_END", _release_mouse)
	Global.subscribe("ENEMY_EXPLODED", _on_enemy_exploded)

func _exit_tree():
	Global.player = null
	Global.unsubscribe("GAME_RESUME", _capture_mouse)
	Global.unsubscribe("GAME_END", _release_mouse)
	Global.unsubscribe("ENEMY_EXPLODED", _on_enemy_exploded)

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var direction := (head.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
	
	if explosion_impulse:
		velocity += explosion_impulse
		explosion_impulse.y = 0
		explosion_impulse = explosion_impulse.move_toward(Vector3.ZERO, 100 * delta)
	move_and_slide()
	
	handle_footsteps(delta)
	

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		_capture_mouse()
	elif event.is_action_pressed("ui_cancel"):
		_release_mouse()
		Global.emit_event("GAME_PAUSE")
	
	if Input.get_mouse_mode() == 2:
		if event is InputEventMouseMotion:
			head.rotate_y(-event.relative.x * Global.look_sensitivity)
			camera.rotate_x(-event.relative.y * Global.look_sensitivity)
			camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-90), deg_to_rad(90)) 

func _process(delta: float) -> void:
	if Input.is_action_pressed("fire_blob") && time_since_last_fired > fire_interval:
		time_since_last_fired = 0.0
		fire_blob()
	else:
		time_since_last_fired += delta
	
	# handle gamepad camera input
	var camera_input := Input.get_vector("camera_left", "camera_right", "camera_up", "camera_down")
	head.rotate_y(-camera_input.x * Global.look_sensitivity * delta * 1000)
	camera.rotate_x(-camera_input.y * Global.look_sensitivity * delta * 1000)
	camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-90), deg_to_rad(90)) 

func fire_blob():
	var blob: RigidBody3D = PAINT_BLOB.instantiate()
	var look_basis = (head.basis * camera.basis)
	var throw_direction = -look_basis.rotated(look_basis.x, deg_to_rad(THROW_ANGLE)).z
	blob.position = position + throw_direction * 0.5
	blob.splash_radius = blob_splash_radius
	blob.apply_impulse(THROW_FORCE * throw_direction, Vector3.ZERO)
	get_parent().add_child(blob)
	
	# play audio
	shot_sound_player.pitch_scale = 0.3 + (0.2 * randf() - 0.1)
	shot_sound_player.play()

func _capture_mouse():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
func _release_mouse():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _on_enemy_exploded(health: int, pos: Vector3):
	var distance = pos.distance_to(global_position)
	if health <= 0:
		# buff for every enemy exploded with black paint
		blob_splash_radius = min(blob_splash_radius + 0.1, MAX_BLOB_SPLASH_RADIUS)
		fire_interval = max(fire_interval * 0.85, MIN_FIRE_INTERVAL)
	elif distance < HIT_BY_PAINT_DISTANCE:
		# debuff only if white exploded enemy nearby
		blob_splash_radius = max(blob_splash_radius - 0.1, MIN_BLOB_SPLASH_RADIUS)
		fire_interval = min(fire_interval * 1.15, MAX_FIRE_INTERVAL)
	
	if distance < HIT_BY_PAINT_DISTANCE:
		var nudge_direction = global_position - pos
		#nudge_direction.y += 1.5
		explosion_impulse = nudge_direction.normalized() * 10

func handle_footsteps(delta):
	footstep_interval = lerp(3.0, 0.6, velocity.length() / SPEED)
	time_since_last_footstep += delta
	if is_on_floor() && velocity.length() > 0 && time_since_last_footstep > footstep_interval:
		time_since_last_footstep = 0
		footstep_sound_player.pitch_scale = 1.0 + (0.2 * randf() - 0.1)
		footstep_sound_player.play()
