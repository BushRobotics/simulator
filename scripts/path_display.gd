extends ColorRect


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

onready var last_origin = AutonPath.get_origin()

# Called when the node enters the scene tree for the first time.
func _ready():
	AutonPath.connect("path_changed", self, "update")
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var origin = AutonPath.get_origin()
	if last_origin.pos != origin.pos or last_origin.rot != origin.rot:
		last_origin = origin
		update()
	pass

func _draw():
	var points = AutonPath.get_global_path()
	for i in range(points.size()):
		points[i].pos -= rect_position
		draw_circle(points[i].pos, 2, Color.deeppink if i == AutonPath.focused_node else Color.red)
		if i != 0:
			draw_line(points[i-1].pos, points[i].pos, Color.red, 1)
