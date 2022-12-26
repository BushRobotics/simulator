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
	var mouse_pos = get_global_mouse_position()
	if event is InputEventMouseButton:
		if not event.pressed:
			focused_node = 0
			return
	elif event is InputEventMouseMotion:
		if not event.pressure > 0:
			focused_node = 0
			return
	else: return
	
	if abs(mouse_pos.x) > 73 or abs(mouse_pos.y) > 73: return

	var path_index = AutonPath.point_near_global(mouse_pos, 8)
	if focused_node == 0:
		if path_index == -1:
			focused_node = AutonPath.add_point(mouse_pos)
			AutonPath.set_focused_node(focused_node)
			return
		if path_index != -1:
			AutonPath.set_focused_node(path_index)
			focused_node = path_index
	
	if focused_node != 0 and event is InputEventMouseMotion:
		AutonPath.set_point_global(AutonPath.focused_node, mouse_pos)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("ui_cancel"):
		hide_red()
		emit_signal("reset")


func show_red():
	$other_side/modulate.show()

func hide_red():
	$other_side/modulate.hide()
