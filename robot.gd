extends KinematicBody2D

enum STATES {TELEPORTING, OP_CONTROL, AUTON}

enum AUTON {MOVING, ROTATING}

var auton_state = AUTON.ROTATING
var target_angle: float = 0
var target_location: Vector2 = Vector2(0, 0)

export var speed: float = 30 # inches per second
export(STATES) var state = STATES.OP_CONTROL

# auton variables
var current_auton_index: int = -1
var current_auton_path = []
onready var start_position: Vector2 = position
onready var start_rotation: float = rotation
var start_speed: float = 0


# Called when the node enters the scene tree for the first time.
func _ready():
	#auton_to(get_parent().get_node("RIGHT").position)
	AutonPath.robot = self
	get_parent().connect("reset", self, "reset_position")
	pass # Replace with function body.
	
func clamp360(angle: float) -> float:
	return fmod(angle + 360, 360)
func vector_within(v: Vector2, t: Vector2, i: int):
	return v.x + i > t.x and v.y + i > t.y and v.x - i < t.x and v.y - 1 < t.y

func teleport_to(pos: Vector2, angle: float = 0):
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
	target_angle = -rotation
	if distance != 0:
		target_angle = asin((position.x - pos.x) / distance)
	target_angle = rad2deg(target_angle)
	if (position - pos).y < 0:
		target_angle *= -1
		print("added 180")
		target_angle += 180
	target_angle = clamp360(target_angle)
	print("current angle: ", clamp360(rotation_degrees))
	print("target angle: ", target_angle)
	print("target position: ", pos)

func play_auton():
	start_speed = speed
	start_position = position
	start_rotation = rotation
	current_auton_index = 0
	current_auton_path = AutonPath.get_global_path()
	speed = current_auton_path[0].speed
	auton_to(current_auton_path[0].pos)

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
		
		if Input.is_action_just_pressed("space"):
			play_auton()
		
		move_by_wheels(left_speed, right_speed)
	
	if state == STATES.TELEPORTING:
		rotation_degrees = lerp(rotation_degrees, target_angle, 0.4)
		position = lerp(position, target_location, 0.4)
		
		if vector_within(position, target_location, 1) and rotation_degrees + 1 > target_angle and rotation_degrees - 1 < target_angle:
			rotation_degrees = target_angle
			position = target_location
			set_collision_layer_bit(0, true)
			set_collision_mask_bit(0, true)
			state = STATES.OP_CONTROL
	
	if state == STATES.AUTON: # this is one of the rare moments where the code on the actual robot will be much cleaner than the godot code
		if auton_state == AUTON.ROTATING:
			var r = clamp360(-rotation_degrees) # equivalent to imu_get_heading()
			#print(r)
			if r + 2 > target_angle and r - 2 < target_angle:
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
			if vector_within(position, target_location, 2):
				print("position: ", position)
				print("target: ", target_location)
				print("error: ", position - target_location)
				print("move done")
				if current_auton_index != -1:
					current_auton_index += 1
					if current_auton_path.size() == current_auton_index:
						state = STATES.OP_CONTROL
						speed = start_speed
						return
					speed = current_auton_path[current_auton_index].speed
					auton_to(current_auton_path[current_auton_index].pos)
			else:
				left_speed = 1
				right_speed = 1
		
		move_by_wheels(left_speed, right_speed)
	#position = mouse_pos - get_viewport_rect().size / 2


func _on_other_side_entered(body):
	if state == STATES.AUTON and body == self:
		print("went on other sied")
		get_parent().show_red()
	pass # Replace with function body.

func reset_position():
	teleport_to(start_position, start_rotation)
