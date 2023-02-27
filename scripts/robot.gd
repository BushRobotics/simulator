extends KinematicBody2D

enum STATES {TELEPORTING, OP_CONTROL, AUTON, IDLE}

enum AUTON {MOVING, ROTATING}

var auton_state = AUTON.ROTATING
var target_angle: float = 0
var target_angle_direction: int = 1
var target_location: Vector2 = Vector2(0, 0)
var target_direction: int = 1

export var speed: float = 30 # inches per second
var robot_width = 17.25 # width in inches

export(STATES) var state = STATES.OP_CONTROL

# auton variables
var current_auton_index: int = -1
var current_auton_path = []
onready var start_position: Vector2 = position
onready var start_rotation: float = rotation
var start_speed: float = 0

var old_state = state


signal action(index)

# Called when the node enters the scene tree for the first time.
func _ready():
	#auton_to(get_parent().get_node("RIGHT").position)
	AutonPath.robot = self
	get_parent().connect("reset", self, "reset_position")

func direction_to(c: int, t: int) -> int:
	c = AutonPath.clamp360(c) as int
	t = AutonPath.clamp360(t) as int
	var a = c - t
	var s = 1 if a >= 0 else -1
	if abs(a) > 180:
		return 1 * s
	return -1 * s

func angle_distance(a, b):
	var w = AutonPath.clamp360(a - b)
	return abs(min(360 - w, w))

func teleport_to(pos: Vector2, angle: float = 0):
	old_state = state
	state = STATES.TELEPORTING
	target_angle = angle
	target_location = pos
	set_collision_layer_bit(0, false)
	set_collision_mask_bit(0, false)

func auton_to(pos: Vector2):
	state = STATES.AUTON
	auton_state = AUTON.ROTATING
	target_location = pos
	var distance := (position - pos).length()
	target_angle = rotation
	target_direction = 1
	if distance != 0:
		target_angle = asin((position.x - pos.x) / distance)
	target_angle = rad2deg(-target_angle)
	if (position - pos).y < 0:
		target_angle *= -1
		print("added 180")
		target_angle += 180
	target_angle = AutonPath.clamp360(target_angle)
	target_angle = floor(target_angle)
	if angle_distance(rotation_degrees, target_angle) > angle_distance(rotation_degrees, target_angle + 180):
		print("target angle is ", target_angle)
		target_angle = AutonPath.clamp360(target_angle + 180)
		target_direction = -1
	target_angle_direction = direction_to(rotation_degrees, target_angle)
	print("current angle: ", AutonPath.clamp360(rotation_degrees))
	print("target angle: ", target_angle)
	print("target position: ", pos)

func play_auton():
	position = start_position
	rotation = start_rotation
	old_state = state if state != STATES.TELEPORTING and state != STATES.AUTON else STATES.IDLE
	set_collision_layer_bit(0, true)
	set_collision_mask_bit(0, true)
	start_speed = speed
	current_auton_index = 0
	current_auton_path = AutonPath.get_global_path()
	speed = current_auton_path[0].speed
	current_auton_path[0].already_rotated = false
	auton_to(current_auton_path[0].pos)

func move_by_wheels(left: float, right: float):
	left /= 10
	right /= 10
	var move_speed = (left + right) / 2
	var theta = asin(left - right) / (robot_width * 6.25) * speed
	rotation += theta
	move_and_slide(Vector2(0, move_speed).rotated(rotation) * -10 * speed)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if state == STATES.IDLE:
		return

	var left_speed: float = 0
	var right_speed: float = 0
	
	if state == STATES.OP_CONTROL: # this state should never occur but if we want it it's here
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
		
		if AutonPath.vector_within(position, target_location, 1) and rotation_degrees + 1 > target_angle and rotation_degrees - 1 < target_angle:
			rotation_degrees = target_angle
			position = target_location
			start_position = position
			start_rotation = rotation
			set_collision_layer_bit(0, true)
			set_collision_mask_bit(0, true)
			state = old_state
	
	if state == STATES.AUTON: # this is one of the rare moments where the code on the actual robot will be much cleaner than the godot code
		if auton_state == AUTON.ROTATING:
			var r = AutonPath.clamp360(rotation_degrees) # equivalent to imu_get_heading()
			if r + 2 >= target_angle and r - 2 <= target_angle:
				auton_state = AUTON.MOVING
				print("rotation done")
			else:
				left_speed += target_angle_direction
				right_speed -= target_angle_direction
		elif auton_state == AUTON.MOVING:
			if AutonPath.vector_within(position, target_location, 2) or current_auton_path[current_auton_index].already_rotated:
				print("move done!")
				if current_auton_index != -1:
					if current_auton_path[current_auton_index].post_angle != null and not current_auton_path[current_auton_index].already_rotated:
						target_angle = current_auton_path[current_auton_index].post_angle + rad2deg(start_rotation)
						target_angle = AutonPath.clamp360(target_angle)
						target_angle = floor(target_angle)
						target_angle_direction = direction_to(rotation_degrees, target_angle)
						auton_state = AUTON.ROTATING
						current_auton_path[current_auton_index].already_rotated = true
						print("post angle: ", target_angle)
						return
					
					if current_auton_path[current_auton_index].action != 0:
						emit_signal("action", current_auton_path[current_auton_index].action)
					current_auton_index += 1
					if current_auton_path.size() == current_auton_index:
						state = old_state
						speed = start_speed
						return
					speed = current_auton_path[current_auton_index].speed
					current_auton_path[current_auton_index].already_rotated = false
					auton_to(current_auton_path[current_auton_index].pos)
			else:
				left_speed = target_direction
				right_speed = target_direction
		
		move_by_wheels(left_speed, right_speed)
	#position = mouse_pos - get_viewport_rect().size / 2


func _on_other_side_entered(body):
	if state == STATES.AUTON and body == self:
		get_parent().show_red()


func reset_position():
	if state == STATES.AUTON:
		state = old_state
	teleport_to(start_position, rad2deg(start_rotation))
