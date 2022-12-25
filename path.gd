extends Node


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var current_path = [
	{
		pos = Vector2(0, 0),
		speed = 30
	},
	{
		pos = Vector2(0, 24),
		speed = 30
	},
	{
		pos = Vector2(24, 24),
		speed = 30
	},
]

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func get_current_path():
	return current_path

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
