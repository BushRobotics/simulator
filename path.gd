extends Node


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var robot: KinematicBody2D

var current_path = [
	{
		pos = Vector2(0, 0),
		speed = 30
	},
	{
		pos = Vector2(0, 24),
		speed = 30
	},
	{
		pos = Vector2(24, 24),
		speed = 30
	},
]

# Called when the node enters the scene tree for the first time.
func _ready():
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

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
