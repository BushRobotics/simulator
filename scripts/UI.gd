extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

signal play_auton
signal go_to(side)

# Called when the node enters the scene tree for the first time.
func _ready():
	AutonPath.connect("path_changed", self, "_on_path_changed")
	for node in get_tree().get_nodes_in_group("numbers"):
		node.connect("text_changed", self, "_on_text_changed", [node.name])

	for node in get_tree().get_nodes_in_group("buttons"):
		node.connect("pressed", self, "_on_button_press", [node])
	pass # Replace with function body.

func _on_path_changed():
	var i = AutonPath.focused_node
	get_tree().get_nodes_in_group("title")[0].text = "pont " + str(i)
	for node in get_tree().get_nodes_in_group("numbers"):
		var val = AutonPath.current_path[i]
		for s in node.name.split("->"):
			val = val[s]
		node.text = str(val)

func _on_text_changed(new_text, node_name):
	var i = AutonPath.focused_node
	if i != 0:
		if node_name == "pos->x":
			return AutonPath.set_point(i, Vector2(float(new_text), AutonPath.current_path[i].pos.y))
		if node_name == "pos->y":
			return AutonPath.set_point(i, Vector2(AutonPath.current_path[i].pos.x, float(new_text)))
	
	if new_text.to_upper() == "NULL":
		AutonPath.current_path[i][node_name] = null
		return
	
	AutonPath.current_path[i][node_name] = new_text as int

func _on_button_press(node: Button):
	match node.text:
		"LEFT":
			emit_signal("go_to", "LEFT")
		"RIGHT":
			emit_signal("go_to", "RIGHT")
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
