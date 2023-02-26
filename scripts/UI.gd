extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


export var file_dialog_path : NodePath
onready var file_dialog : FileDialog = get_node(file_dialog_path)
export var confirmation_dialog_path : NodePath
onready var confirmation_dialog: ConfirmationDialog = get_node(confirmation_dialog_path)
signal play_auton
signal go_to(side)

signal focus_leave
signal focus_return

var file_path: String

func _ready() -> void:
	file_dialog.connect("file_selected",self,"file_dialog_file_selected")
	file_dialog.connect("popup_hide",self,"file_dialog_popup_hide")
	confirmation_dialog.connect("confirmed",self,"confirmation_dialog_confirmed")
	
	AutonPath.connect("path_changed", self, "_on_path_changed")
	for node in get_tree().get_nodes_in_group("numbers"):
		node.connect("text_changed", self, "_on_text_changed", [node.name])

	for node in get_tree().get_nodes_in_group("buttons"):
		node.connect("pressed", self, "_on_button_press", [node])

func _on_path_changed() -> void:
	var i = AutonPath.focused_node
	get_tree().get_nodes_in_group("title")[0].text = "pont " + str(i)
	for node in get_tree().get_nodes_in_group("numbers"):
		var val = AutonPath.current_path[i]
#		var p = node.line_edit.caret_position
		for s in node.name.split("->"):
			val = val[s]
		if val == null:
			return
		node.value = val
#		node.caret_position = p

func _on_text_changed(new_text, node_name):
	if new_text == "":
		return
	var i = AutonPath.focused_node
	if i != 0:
		if node_name == "pos->x":
			AutonPath.set_point(i, Vector2(float(new_text), AutonPath.current_path[i].pos.y))
		elif node_name == "pos->y":
			AutonPath.set_point(i, Vector2(AutonPath.current_path[i].pos.x, float(new_text)))
	
	if new_text.to_upper() == "NULL":
		AutonPath.current_path[i][node_name] = null
		return
	
	AutonPath.current_path[i][node_name] = new_text as int

func _on_button_press(node: Button) -> void:
	var i = AutonPath.focused_node
	match node.text:
		"LEFT":
			emit_signal("go_to", "LEFT")
		"RIGHT":
			emit_signal("go_to", "RIGHT")
		"delete node":
			AutonPath.remove_point(i)
		"clear":
			confirmation_dialog.popup()
			emit_signal("focus_leave")
		"play":
			emit_signal("play_auton")
		"save":
			emit_signal("focus_leave")
			file_dialog.mode = FileDialog.MODE_SAVE_FILE
			file_dialog.popup()
		"load":
			emit_signal("focus_leave")
			file_dialog.mode = FileDialog.MODE_OPEN_FILE
			file_dialog.popup()

func confirmation_dialog_confirmed() -> void:
	AutonPath.clear_path()
	emit_signal("focus_return")

func file_dialog_popup_hide() -> void:
	emit_signal("focus_return")

func file_dialog_file_selected(path : String) -> void:
	if file_dialog.mode == 4:
		AutonPath.save_to(path)
	else:
		AutonPath.load_from(path)
	emit_signal("focus_return")
	file_dialog.hide()
