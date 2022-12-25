extends KinematicBody2D

enum STATES {TELEPORTING, OP_CONTROL, AUTON}

enum AUTON {STARTING, MOVING, ROTATING, DONE}

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var target_angle: float = 0
var target_location: Vector2 = Vector2(0, 0)

export var speed = 30 # inches per second
export(STATES) var state = STATES.TELEPORTING



# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func teleport_to(pos: Vector2, angle: float = 0):
	state = STATES.TELEPORTING
	target_angle = angle
	target_location = pos

func move_by_wheels(left: float, right: float):
	var move_speed = (left + right) / 2
	var theta = asin(left - right) / 100 * speed
	rotation += theta
	move_and_slide(Vector2(0, move_speed).rotated(rotation) * -10 * speed)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var left_speed: float = 0
	var right_speed: float = 0
	
	if state == STATES.OP_CONTROL:
		if Input.is_action_pressed("up"):
			left_speed += 1
			right_speed += 1
		if Input.is_action_pressed("down"):
			left_speed -= 1
			right_speed -= 1
			
		if Input.is_action_pressed("right"):
			right_speed -= 1
			left_speed += 1
		if Input.is_action_pressed("left"):
			right_speed += 1
			left_speed -= 1
		
		move_by_wheels(left_speed / 10, right_speed / 10)
	
	if state == STATES.TELEPORTING:
		rotation_degrees = lerp(rotation_degrees, target_angle, 0.4)
		position = lerp(position, target_location, 0.4)
		
		if position == target_location and rotation_degrees == target_angle:
			state = STATES.OP_CONTROL
	
	if state == STATES.AUTON:
		
		
		move_by_wheels(left_speed / 10, right_speed / 10)
		pass
	#position = mouse_pos - get_viewport_rect().size / 2
