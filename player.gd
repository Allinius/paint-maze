class_name Player
extends CharacterBody3D

@onready var head: Node3D = $Head
@onready var camera: Camera3D = $Head/Camera3D

const PAINT_BLOB = preload("uid://c5ybl7jbx7jpb")
const THROW_FORCE = 13.0
const THROW_ANGLE = 15.0

const SPEED = 5.0
const JUMP_VELOCITY = 4.5

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	Global.player = self
	Global.subscribe("GAME_RESUME", _capture_mouse)
	Global.subscribe("GAME_END", _release_mouse)

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
	move_and_slide()


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		_capture_mouse()
		if event.button_index == MOUSE_BUTTON_LEFT && event.pressed:
			fire_blob()
	elif event.is_action_pressed("ui_cancel"):
		_release_mouse()
		Global.emit_event("GAME_PAUSE")
	
	if Input.get_mouse_mode() == 2:
		if event is InputEventMouseMotion:
			head.rotate_y(-event.relative.x * Global.look_sensitivity)
			camera.rotate_x(-event.relative.y * Global.look_sensitivity)
			camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-90), deg_to_rad(90)) 

func fire_blob():
	var blob: RigidBody3D = PAINT_BLOB.instantiate()
	var look_basis = (head.basis * camera.basis)
	var throw_direction = -look_basis.rotated(look_basis.x, deg_to_rad(THROW_ANGLE)).z
	blob.position = position
	blob.apply_impulse(THROW_FORCE * throw_direction, Vector3.ZERO)
	get_parent().add_child(blob)

func _capture_mouse():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
func _release_mouse():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _exit_tree():
	Global.player = null
	Global.unsubscribe("GAME_RESUME", _capture_mouse)
	Global.unsubscribe("GAME_END", _release_mouse)
