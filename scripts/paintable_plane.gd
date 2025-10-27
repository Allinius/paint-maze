class_name PaintablePlane
extends Node3D

@onready var mesh_instance: MeshInstance3D = $MeshInstance3D
@onready var collision_shape: CollisionShape3D = $CollisionShape3D

@export var plane_size = Vector2(4, 4)
@export var texture_size = Vector2i(128, 128)
@export var fill_color: Color = Color.WHITE
@export var random_color: bool = false

var image : Image
var image_texture : ImageTexture
var material_instance : StandardMaterial3D


func _ready() -> void:
	init_mesh()
	init_texture()
		

func init_mesh():
	#var mesh := PlaneMesh.new()
	#mesh.size = plane_size
	#mesh_instance.mesh = mesh
	mesh_instance.mesh.size = plane_size
	
	#var collision_box: BoxShape3D = BoxShape3D.new()
	collision_shape.shape.size = Vector3(plane_size.x, 0.1, plane_size.y)
	#collision_shape.shape = collision_box

func init_texture():
	image = Image.create(texture_size.x, texture_size.y, false, Image.FORMAT_RGBA8)
	if random_color:
		image.fill(Color(randf(), randf(), randf(), 1))
	else:
		image.fill(fill_color)
		
		

	image_texture = ImageTexture.create_from_image(image)

	material_instance = StandardMaterial3D.new()
	material_instance.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST
	material_instance.albedo_texture = image_texture
	mesh_instance.material_override = material_instance

func paint_world_point(world_point: Vector3, radius: float, color: Color):
	var local_point = mesh_instance.to_local(world_point)
	var uv = Vector2(
		0.5 + (local_point.x / plane_size.x),
		0.5 - (local_point.z / plane_size.y)
	)
	var distance = abs(local_point.y / plane_size.x)
	
	var edge_margin = 0.05
	if uv.x < edge_margin && uv.x > -edge_margin:
		uv.x -= distance
	if uv.y < edge_margin && uv.y > -edge_margin:
		uv.y -= distance
	if uv.x > 1 - edge_margin && uv.x < 1 + edge_margin:
		uv.x += distance
	if uv.y > 1 - edge_margin && uv.y < 1 + edge_margin:
		uv.y += distance
	
	paint_uv(uv, get_pixel_radius(radius), color)

#func paint_uv(uv: Vector2, radius: float, color: Color):
	#var x = int(uv.x * texture_size.x)
	#var y = int((1.0 - uv.y) * texture_size.y)
#
	##image.fill_rect(Rect2i(x - radius, y - radius, 2 * radius, 2 * radius), color)
	#for i in range(-radius, radius):
		#for j in range(-radius, radius):
			#if i * i + j * j <= radius * radius:
				#var px = x + i
				#var py = y + j
				#if px >= 0 && px < texture_size.x && py >= 0 && py < texture_size.y:
					#image.set_pixel(px, py, color)
	#image_texture.update(image)

func paint_uv(uv: Vector2, radius: float, color: Color):
	var x = int(uv.x * texture_size.x)
	var y = int((1.0 - uv.y) * texture_size.y)
	var r = int(radius)
	var r_sq = radius * radius

	for j in range(-r, r + 1):
		var dy_sq = j * j
		if dy_sq > r_sq:
			continue
		var dx = int(sqrt(r_sq - dy_sq))
		var start_x = clamp(x - dx, 0, texture_size.x - 1)
		var end_x = clamp(x + dx, 0, texture_size.x - 1)
		var py = y + j
		if py >= 0 and py < texture_size.y:
			image.fill_rect(Rect2i(start_x, py, end_x - start_x + 1, 1), color)
	image_texture.update(image)

func will_paint(uv: Vector2, radius: float):
	var uvrad = Vector2(radius / texture_size.x, radius / texture_size.y)
	return uv.x >= -uvrad.x && uv.x <= 1 + uvrad.x && uv.y >= -uvrad.y && uv.y <= 1 + uvrad.y

func get_pixel_radius(unit_radius: float):
	var pixel_in_units = plane_size.x / texture_size.x
	return floor(unit_radius / pixel_in_units)
	
