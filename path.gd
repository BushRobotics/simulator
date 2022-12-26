extends Node


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var robot: KinematicBody2D
signal path_changed

var current_path = []

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
	if robot.state == robot.STATES.AUTON:
		return {
			pos = robot.start_position,
			rot = robot.start_rotation
		}
	return {
		pos = robot.position,
		rot = robot.rotation
	}



func add_point(coords: Vector2):
	var origin = get_origin()
	coords = coords.rotated(-origin.rot) - origin.pos
	coords.y *= -1
	current_path.append({
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
