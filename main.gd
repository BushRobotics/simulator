extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
signal reset

var focused_node = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _input(event):
	if event is InputEventMouseButton:
		if not event.pressed:
			focused_node = 0
			return
	elif event is InputEventMouseMotion:
		if not event.pressure > 0:
			focused_node = 0
			return
	else:
		return
	#$Robot.teleport_to(get_global_mouse_position())
	var mouse_pos = get_global_mouse_position()
	var path_index = AutonPath.point_near_global(mouse_pos, 5)
	if focused_node == 0:
		if path_index == -1:
			AutonPath.add_point(mouse_pos)
			focused_node = AutonPath.current_path.size() - 1
			return
	if path_index != -1:
		focused_node = path_index
	if focused_node != 0:
		AutonPath.set_point_global(focused_node, mouse_pos)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("ui_cancel"):
		hide_red()
		emit_signal("reset")


func show_red():
	$other_side/modulate.show()

func hide_red():
	$other_side/modulate.hide()
