extends CanvasLayer

export var angle_null_button_path : NodePath
onready var angle_null_button : CheckBox = get_node(angle_null_button_path)

export var file_dialog_path : NodePath
onready var file_dialog : FileDialog = get_node(file_dialog_path)

export var confirmation_dialog_path : NodePath
onready var confirmation_dialog: ConfirmationDialog = get_node(confirmation_dialog_path)

export var post_angle_path : NodePath
onready var post_angle_box : SpinBox = get_node(post_angle_path)

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
		var line_edit: LineEdit = node.get_line_edit()
		node.connect("value_changed", self, "_on_text_changed", [node, line_edit])
		line_edit.connect("text_changed", self, "_on_text_changed", [node, line_edit])

	for node in get_tree().get_nodes_in_group("buttons"):
		node.connect("pressed", self, "_on_button_press", [node])

func _on_path_changed() -> void:
	var i = AutonPath.focused_node
	get_tree().get_nodes_in_group("title")[0].text = "point " + str(i)
	for node in get_tree().get_nodes_in_group("numbers"):
		var val = AutonPath.current_path[i]
#		var p = node.line_edit.caret_position
		for s in node.name.split("->"):
			val = val[s]
		if val == null:
			node.value = 0
		else:
			node.value = val
	angle_null_button.set_pressed_no_signal(AutonPath.current_path[i].post_angle != null)

func _on_text_changed(new_text, node: SpinBox, line_edit: LineEdit):
	var caret = line_edit.get_cursor_position()
	node.apply()
	line_edit.set_cursor_position(caret)
	var i = AutonPath.focused_node
	if i != 0:
		if node.name == "pos->x":
			AutonPath.set_point(i, Vector2(float(node.value), AutonPath.current_path[i].pos.y))
			return
		elif node.name == "pos->y":
			AutonPath.set_point(i, Vector2(AutonPath.current_path[i].pos.x, float(node.value)))
			return
	
	if node.name == "post_angle" and not angle_null_button.pressed:
		angle_null_button.set_pressed_no_signal(true)
		return

	AutonPath.current_path[i][node.name] = int(node.value)

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
		"null":
			if angle_null_button.pressed:
				AutonPath.current_path[i].post_angle = post_angle_box.value
			else:
				AutonPath.current_path[i].post_angle = null

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
