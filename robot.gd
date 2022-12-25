extends KinematicBody2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
export var left_speed = 0.1
export var right_speed = 0.1
var fac = 0.001

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_pressed("left_down"):
		left_speed -= fac
	if Input.is_action_pressed("left_up"):
		left_speed += fac
		
	if Input.is_action_pressed("right_down"):
		right_speed -= fac
	if Input.is_action_pressed("right_up"):
		right_speed += fac
		
	var theta = asin(left_speed - right_speed)
	
	rotation += theta
	
	position += Vector2(0, (left_speed + right_speed / 2)).rotated(rotation) * -1
	
	print("left speed:", left_speed)
	print("right speed:", right_speed)
	
	#position = mouse_pos - get_viewport_rect().size / 2
