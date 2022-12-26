extends RigidBody2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
onready var start_position := position
var reset_state = false
# Called when the node enters the scene tree for the first time.
func _ready():
	get_node("/root/main").connect("reset", self, "reset_position")
	pass # Replace with function body.

func reset_position():
	reset_state = true
	sleeping = false
	apply_impulse(Vector2(0, 0), Vector2(0, 0))
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _integrate_forces(state):
	if reset_state:
		state.set_transform(Transform2D(0, start_position))
		reset_state = false
		#sleeping = true
