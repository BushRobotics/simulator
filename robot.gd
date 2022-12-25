extends KinematicBody2D

enum STATES {TELEPORTING, OP_CONTROL, AUTON}

enum AUTON {MOVING, ROTATING}

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var auton_state = AUTON.ROTATING
var target_angle: float = 0
var target_location: Vector2 = Vector2(0, 0)

export var speed: float = 30 # inches per second
export(STATES) var state = STATES.OP_CONTROL


# Called when the node enters the scene tree for the first time.
func _ready():
	#auton_to(get_parent().get_node("RIGHT").position)
	pass # Replace with function body.
	
func clamp360(angle: float) -> float:
	return fmod(angle + 360, 360)
	

func teleport_to(pos: Vector2, angle: float = 0):
	state = STATES.TELEPORTING
	target_angle = angle
	target_location = pos

func auton_to(pos: Vector2):
	state = STATES.AUTON
	auton_state = AUTON.ROTATING
	target_location = pos
	target_angle = asin((position.x - pos.x) / (position - pos).length())
	target_angle = rad2deg(target_angle)
	print("before transflorm: ", target_angle)
	if (position - pos).y < 0:
		print("not adding 180 lol")
		target_angle *= -1
		target_angle += 180
	target_angle = clamp360(target_angle)
	print("final target: ", target_angle)

func move_by_wheels(left: float, right: float):
	left /= 10
	right /= 10
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
		
		move_by_wheels(left_speed, right_speed)
	
	if state == STATES.TELEPORTING:
		rotation_degrees = lerp(rotation_degrees, target_angle, 0.4)
		position = lerp(position, target_location, 0.4)
		
		if position == target_location and rotation_degrees == target_angle:
			state = STATES.OP_CONTROL
	
	if state == STATES.AUTON: # this is one of the rare moments where the code on the actual robot will be much cleaner than the godot code
		if auton_state == AUTON.ROTATING:
			var r = clamp360(rotation_degrees * -1) # equivalent to imu_get_heading()
			print(r)
			if r + 5 > target_angle and r - 5 < target_angle:
				auton_state = AUTON.MOVING
				print("rotation done")
			else:
				if clamp360(r - target_angle) > 180:
					left_speed -= 1
					right_speed += 1
				else:
					left_speed += 1
					right_speed -= 1
		elif auton_state == AUTON.MOVING:
			if position + Vector2(2, 2) > target_location and position - Vector2(2, 2) < target_location:
				state = STATES.OP_CONTROL # TODO: actual playback with more than one step
				print("move done")
			else:
				left_speed = 1
				right_speed = 1
		
		move_by_wheels(left_speed, right_speed)
	#position = mouse_pos - get_viewport_rect().size / 2
