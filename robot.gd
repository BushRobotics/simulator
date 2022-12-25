extends KinematicBody2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

export var speed = 3


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func move_by_wheels(left: float, right: float):
	var move_speed = (left + right) / 2 
	var theta = asin(left - right) / 10 * speed
	rotation += theta
	move_and_slide(Vector2(0, move_speed).rotated(rotation) * -100 * speed)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var left_speed: float = 0
	var right_speed: float = 0
	
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
	
	
	#position = mouse_pos - get_viewport_rect().size / 2
