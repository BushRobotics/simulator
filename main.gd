extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
signal reset

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _input(event):
	if event is InputEventMouseButton:
		if event.pressed:
			#$Robot.teleport_to(get_global_mouse_position())
			AutonPath.add_point(get_global_mouse_position())

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("ui_cancel"):
		hide_red()
		emit_signal("reset")


func show_red():
	$other_side/modulate.show()

func hide_red():
	$other_side/modulate.hide()
