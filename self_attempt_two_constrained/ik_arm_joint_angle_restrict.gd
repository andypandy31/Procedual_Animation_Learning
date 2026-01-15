extends Node2D

@export var number_joints : int = 50
@export var joint_length : int = 10
@export var root : Vector2 = Vector2(500,500)
@export var head_follow_speed : int = 5

@onready var target := get_node_or_null("../Traget_Path/Target_PathFollow") as PathFollow2D

var stiffness : float = 0.8
# joints = { pos, min_angle, max_angle, dir }
var joints : Array[Dictionary] = []

class Joint:
	var pos: Vector2
	var min_angle: float
	var max_angle: float

func _ready() -> void:
	joint_creation()


func joint_creation():
	joints.clear()
	for i in range(number_joints):
		#joints.append root, -deg_to_rad(), deg_to_rad() to provide a frame to work the segments 
		joints.append({
			"pos": root + Vector2(joint_length * i, 0),
			"min": -deg_to_rad(140),
			"max":  deg_to_rad(140),
		})

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	update_joints(target.global_position)
	queue_redraw()


func update_joints(target: Vector2,):
	var joint_count := joints.size()
	
	# Forward pass (end effector -> root)
	joints[joint_count - 1]["pos"] = target
	for i in range(joint_count - 2, -1, -1):
		var child = joints[i + 1]
		var joint = joints[i]
		var dir = (joint["pos"] - child["pos"]).normalized()
		joint["pos"] = child["pos"] + dir * joint_length
		
	# Backward pass (root -> end effector)
	joints[0]["pos"] = root

	for i in range(1, joint_count):
		var prev = joints[i - 1]
		var joint = joints[i]
		
		var dir = (joint["pos"] - prev["pos"]).normalized()
		var ref_dir : Vector2
		if i == 1:
			ref_dir = Vector2.RIGHT
			joint["pos"] = prev["pos"] + dir * joint_length
		else:
			ref_dir = (prev["pos"] - joints[i - 2]["pos"]).normalized()
			var angle = ref_dir.angle_to(dir)
			angle = lerp(angle, clamp(angle, joint["min"], joint["max"]), stiffness)
			dir = ref_dir.rotated(angle)
			joint["pos"] = prev["pos"] + dir * joint_length

func _draw():
	# Draw spine
	for i in joints.size():
		if i > 0:
			draw_line( joints[i - 1]["pos"], joints[i]["pos"], Color.GREEN, 3)
	draw_circle(joints[0]["pos"], 15, Color.RED)
