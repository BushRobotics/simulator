extends Node

var robot: KinematicBody2D
signal path_changed

var current_path = []
var focused_node = 0

func between_points(current_point, point1, point2, threshold) -> bool:
	var p2dist = point2 - point1
	if p2dist.x == 0 or p2dist.y == 0:
		return false
	
	var dx = (current_point.x - point1.x) / p2dist.x
	var dy = (current_point.y - point1.y) / p2dist.y
	var on_line = dx + threshold > dy and dx - threshold < dy
	
	var between_x = dx >= 0 and dx <= 1
	var between_y = dy >= 0 and dy <= 1
	
	return on_line and between_y and between_x

func vector_within(v: Vector2, t: Vector2, i: int):
	return (v - t).length() <= i

func clamp360(angle: int) -> int:
	while angle > 360 or angle < 0:
		angle = (angle + 360) % 360
	return angle

func point_near_global(point: Vector2, threshold: int) -> int:
	point = global_to_local(point)
	for i in range(current_path.size()):
		if vector_within(point, current_path[i].pos, threshold):
			return i
	return -1

func set_point(index: int, pos: Vector2):
	current_path[index].pos = pos
	emit_signal("path_changed")

func set_point_global(index: int, pos: Vector2):
	set_point(index, global_to_local(pos))

func remove_point(index: int):
	if index == 0:
		return
	if index == focused_node:
		focused_node -= 1
	current_path.remove(index)
	emit_signal("path_changed")

# Called when the node enters the scene tree for the first time.
func _ready():
	clear_path()
	pass # Replace with function body.

func get_global_path():
	var p = []
	var origin = get_origin()
	for i in range(current_path.size()):
		p.append(current_path[i].duplicate())
		p[i].pos.y  *= -1
		p[i].pos = p[i].pos.rotated(origin.rot) + origin.pos
		
	return p

func get_origin():
	if not robot:
		return {pos = Vector2(0, 0), rot = 0}

	return {
		pos = robot.start_position,
		rot = robot.start_rotation
	}

func global_to_local(coords: Vector2):
	var origin = get_origin()
	coords = (coords - origin.pos).rotated(-origin.rot)
	coords.y *= -1
	return coords

func set_focused_node(index: int):
	focused_node = index
	emit_signal("path_changed")

func add_point(coords: Vector2) -> int:
	coords = global_to_local(coords)
	var arr_pos = current_path.size()
	for i in range(current_path.size()):
		if i == current_path.size() - 1:
			break
		if between_points(coords, current_path[i].pos, current_path[i + 1].pos, 20):
			arr_pos = i + 1
			break
	current_path.insert(arr_pos, {
		pos = coords,
		speed = current_path[-1].speed,
		action = 0,
		post_angle = null
	})
	emit_signal("path_changed")
	return arr_pos

func clear_path():
	current_path = [
		{
			pos = Vector2(0, 0),
			speed = 30,
			action = 0,
			post_angle = null
		}
	]
	focused_node = 0
	emit_signal("path_changed")

func save_to(fname):
	print("saving path to", fname)
	var data = ""
	
	for point in current_path:
		data += str(point.pos.x) + " "
		data += str(point.pos.y) + " "
		data += str(point.speed) + " "
		data += str(point.action) + " "
		if point.post_angle != null:
			data += str(clamp360(point.post_angle))
		else:
			data += "N"
		data += "\n"
	var file = File.new()
	file.open(fname, File.WRITE)
	file.store_string(data)
	file.close()

func load_from(fname):
	current_path = []
	focused_node = 0
	var file = File.new()
	file.open(fname, File.READ)
	var data = file.get_as_text()
	file.close()
	
	for p in data.split("\n", false):
		p = p.split(" ")
		var point = {
			post_angle = null
		}
		point.pos = Vector2(float(p[0]), float(p[1]))
		point.speed = int(p[2])
		point.action = int(p[3])
		if p[4] != "N":
			point.post_angle = int(p[4])
		current_path.append(point)
	emit_signal("path_changed")	
