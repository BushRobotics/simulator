extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var flashing = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func show_action(index):
	show()
	$Label.text = str(index)
	modulate.a = 0
	flashing = 1

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if flashing > 0:
		modulate.a += 0.06
		if modulate.a > 1:
			flashing = -1
	if flashing < 0:
		modulate.a -= 0.06
		if modulate.a < 0:
			flashing = 0
			hide()
