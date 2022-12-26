extends Node


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var robot: KinematicBody2D
signal path_changed

var current_path = []

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
	return v.x + i > t.x and v.y + i > t.y and v.x - i < t.x and v.y - 1 < t.y

func point_near_global(point: Vector2, threshold: int) -> int:
	point = global_to_local(point)
	for i in range(current_path.size()):
		if vector_within(point, current_path[i].pos, threshold):
			return i
	return -1

func set_point_global(index: int, pos: Vector2):
	current_path[index].pos = global_to_local(pos)
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
	if robot.state == robot.STATES.AUTON:
		return {
			pos = robot.start_position,
			rot = robot.start_rotation
		}
	return {
		pos = robot.position,
		rot = robot.rotation
	}

func global_to_local(coords: Vector2):
	var origin = get_origin()
	coords = coords.rotated(-origin.rot) - origin.pos
	coords.y *= -1
	return coords

func add_point(coords: Vector2):
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
		speed = current_path[-1].speed
	})
	emit_signal("path_changed")

func clear_path():
	current_path = [
		{
			pos = Vector2(0, 0),
			speed = 30
		}
	]
	emit_signal("path_changed")
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
