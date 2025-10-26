extends Area3D

const PAINT_BLOB = preload("uid://c5ybl7jbx7jpb")

@onready var nav_agent: NavigationAgent3D = $NavigationAgent3D
@onready var sprite_3d: Sprite3D = $Sprite3D
@onready var animation_player: AnimationPlayer = $AnimationPlayer

@export var speed: float = 1.5
@export var health := 3
@export var explode_blobs_count := 15
@export var explode_force := 10.0
@export var explode_blob_splash_radius = 1.5

var navigating := true
var direction: Vector3
var exploded := false

func _physics_process(_delta: float) -> void:
	if navigating:
		update_direction()

func _process(delta: float) -> void:
	if navigating:
		move(delta)
		if !animation_player.is_playing():
			animation_player.play("idle")
	look_at_player()

func update_direction() -> void:
	if !Global.player:
		return
	nav_agent.target_position = Global.player.global_position
	var next_path_pos := nav_agent.get_next_path_position()
	direction = global_position.direction_to(next_path_pos)
	
	if nav_agent.is_navigation_finished():
		print("destructing")
		self_destruct()

func move(delta: float):
	if !direction:
		return
	position = position + speed * delta * direction

func look_at_player() -> void:
	if Global.player:
		sprite_3d.look_at(Global.player.global_position, Vector3.UP)

func self_destruct() -> void:
	navigating = false
	animation_player.play("self_destruct")
	print("connected")
	pass

func _on_body_entered(body: Node3D) -> void:
	if body is PaintBlob && !exploded:
		if navigating:
			animation_player.play(["hit1", "hit2"][health % 2])
		body.queue_free()
		health -= 1
		if health == 0:
			self_destruct()

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "self_destruct":
		animation_player.play("fade_out")
		explode_paint()
	if anim_name == "fade_out":
		queue_free()

func explode_paint():
	exploded = true
	for i in range(explode_blobs_count):
		var blob: PaintBlob = PAINT_BLOB.instantiate()
		blob.color = Color.BLACK if health <= 0 else Color.WHITE
		blob.splash_radius = explode_blob_splash_radius
		blob.position = Vector3(position.x, position.y + 1.5, position.z)
		blob.apply_impulse(explode_force * Global.random_direction_3d(), Vector3.ZERO)
		get_parent().add_child(blob)
	
