extends Node3D

const PAINTABLE_PLANE = preload("uid://xbm7r54x7f3w")
const PLAYER = preload("uid://droy5n4ft44ag")
const PLANE_SIZE = Vector2(4, 4)

const WALL = 0
const FLOOR = 1000

var map: Array[Array]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	map = generate_maze(9, 9)
	var counts := count_steps(map)
	print_maze(map)
	print(counts)
	create_map(map)
	spawn_player(counts[0][0])

func generate_maze(width: int, height: int) -> Array[Array]:
	var maze: Array[Array] = []
	for y in range(height):
		maze.append([])
		for x in range(width):
			maze[y].append(WALL)
	
	var start = Vector2i(1, 1)
	maze[start.y][start.x] = FLOOR
	
	var stack: Array = [start]
	while stack.size() > 0:
		var current = stack[-1]
		var neighbors = get_unvisited_neighbors(maze, current)

		if neighbors.size() > 0:
			var next = neighbors.pick_random()
			
			var wall = (current + next) / 2
			maze[wall.y][wall.x] = FLOOR
			maze[next.y][next.x] = FLOOR
			stack.append(next)
		else:
			stack.pop_back()
	
	var walls_to_delete: int = floor((width * height) / 20.0)
	print(walls_to_delete)
	for i in range(walls_to_delete):
		while true:
			var x = 1 + (randi() % (width - 2))
			var y = 1 + (randi() % (height - 2))
			if maze[y][x] == WALL:
				maze[y][x] = FLOOR
				break
			
	return maze

func get_unvisited_neighbors(maze: Array[Array], cell: Vector2i) -> Array:
	var width = maze[0].size()
	var height = maze.size()
	var dirs = [
		Vector2i(0, -2), # north
		Vector2i(0, 2), # south
		Vector2i(-2, 0), # west
		Vector2i(2, 0) # east
	]

	var result = []
	for dir in dirs:
		var x = cell.x + dir.x
		var y = cell.y + dir.y
		if x > 0 && x < width - 1 && y > 0 && y < height - 1:
			if maze[y][x] == WALL:
				result.append(Vector2i(x, y))
	return result

func print_maze(maze: Array[Array]) -> void:
	var width = maze[0].size()
	var height = maze.size()
	var out = ""
	for y in range(height):
		for x in range(width):
			out += "##" if maze[y][x] == WALL else str(maze[y][x]).lpad(2, " ")
		out += "\n"
	print(out)

func create_map(maze: Array[Array]) -> void:
	var width = maze[0].size()
	var height = maze.size()
	for y in range(height):
		for x in range(width):
			if maze[y][x] != WALL:
				create_walls(maze, x, y)


func create_walls(maze: Array[Array], x: int, y: int):
	var floor_plane = PAINTABLE_PLANE.instantiate()
	floor_plane.plane_size = PLANE_SIZE
	floor_plane.position = Vector3(PLANE_SIZE.x * x, 0, PLANE_SIZE.y * y)
	add_child(floor_plane)
	
	var ceil_plane: PaintablePlane = PAINTABLE_PLANE.instantiate()
	ceil_plane.plane_size = PLANE_SIZE
	ceil_plane.position = Vector3(PLANE_SIZE.x * x, PLANE_SIZE.y, PLANE_SIZE.y * y)
	ceil_plane.transform.basis = ceil_plane.transform.basis.rotated(Vector3.RIGHT, deg_to_rad(180))
	add_child(ceil_plane)
	
	var directions = ["up", "down", "left", "right"]
	var dir_vectors = {
		"up": Vector2i(0, -1),
		"down": Vector2i(0, 1),
		"left": Vector2i(-1, 0),
		"right": Vector2i(1, 0),
	}
	var dir_rotations = {
		"up": { "axis": Vector3.LEFT, "angle": deg_to_rad(90) },
		"down": { "axis": Vector3.LEFT, "angle": deg_to_rad(-90) },
		"left": { "axis": Vector3.BACK, "angle": deg_to_rad(90) },
		"right": { "axis": Vector3.BACK, "angle": deg_to_rad(-90) },
	}
	for dir in directions:
		var coord = Vector2i(x, y) + dir_vectors[dir]
		if maze[coord.y][coord.x] == WALL:
			var wall_plane: PaintablePlane = PAINTABLE_PLANE.instantiate()
			wall_plane.plane_size = PLANE_SIZE
			wall_plane.position = Vector3(
				PLANE_SIZE.x * x + (dir_vectors[dir].x * PLANE_SIZE.x / 2), 
				PLANE_SIZE.y / 2,
				PLANE_SIZE.y * y + (dir_vectors[dir].y * PLANE_SIZE.y / 2)
			)
			wall_plane.transform.basis = ceil_plane.transform.basis.rotated(dir_rotations[dir]["axis"], dir_rotations[dir]["angle"])
			add_child(wall_plane)

func spawn_player(pos: Vector2i):
	var player= PLAYER.instantiate()
	player.position = Vector3(PLANE_SIZE.x * pos.x, 1, PLANE_SIZE.y * pos.y)
	add_child(player)

func get_neighbor_floors(maze: Array[Array], cell: Vector2i) -> Array:
	var width = maze[0].size()
	var height = maze.size()
	var dirs = [
		Vector2i(0, -1), # north
		Vector2i(0, 1), # south
		Vector2i(-1, 0), # west
		Vector2i(1, 0) # east
	]

	var result = []
	for dir in dirs:
		var x = cell.x + dir.x
		var y = cell.y + dir.y
		if x > 0 && x < width - 1 && y > 0 && y < height - 1:
			if maze[y][x] == FLOOR:
				result.append(Vector2i(x, y))
	return result
	
func count_steps(maze: Array[Array]) -> Array[Array]:
	var width = maze[0].size()
	var height = maze.size()
	var start = Vector2i(randi() % width, randi() % height)
	while maze[start.y][start.x] == WALL:
		start = Vector2i(randi() % width, randi() % height)
	
	var result: Array[Array] = []
	maze[start.y][start.x] = 1
	var stack = [start]
	
	while stack.size() > 0:
		var curr = stack.pop_front()
		var curr_steps = maze[curr.y][curr.x]
		
		if result.size() < curr_steps:
			result.append([])
		result[curr_steps - 1].push_back(curr)
		
		var neighbors = get_neighbor_floors(maze, curr)
		for neighbor in neighbors:
			maze[neighbor.y][neighbor.x] = curr_steps + 1
			stack.push_back(neighbor)
		
	return result
