extends Node2D

@export var number_joints : int = 10
@export var joint_length : int = 50
@export var root : Vector2 = Vector2(500,500)
@export var head_follow_speed : int = 5

@onready var target := get_node_or_null("../Traget_Path/Target_PathFollow") as PathFollow2D

var joints : Array[Vector2] = []


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	joint_creation()


func joint_creation():
	joints.clear()
	for i in range(number_joints):
		joints.append(root)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	update_joints(joints, target.global_position)
	queue_redraw()

func update_joints(joints: Array[Vector2], target: Vector2,):
	var joint_count := joints.size()

	# Forward pass (end effector -> root)
	joints[joint_count - 1] = target
	for i in range(joint_count - 2, -1, -1):
		var dir := (joints[i] - joints[i + 1]).normalized()
		joints[i] = joints[i + 1] + dir * joint_length

	# Backward pass (root -> end effector)
	joints[0] = root
	for i in range(1, joint_count):
		var dir := (joints[i] - joints[i - 1]).normalized()
		joints[i] = joints[i - 1] + dir * joint_length


func _draw():
	# Draw spine
	for i in range(joints.size() - 1):
		draw_line(joints[i], joints[i + 1], Color.GREEN, 3)
	
	draw_circle(joints[0], 15, Color.RED)
