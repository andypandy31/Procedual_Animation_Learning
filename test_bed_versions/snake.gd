extends Node2D

@onready var target_auto := get_node_or_null("../Traget_Path/Target_PathFollow") as PathFollow2D

@export var spine_segment_count := 20
@export var spine_segment_length := 20.0

@export var arm_segment_count := 4
@export var arm_segment_length := 20

@export var arm_max_distance := 100.0
@export var head_follow_speed := 10.0

enum {
	LIMB_LEN,
	LIMB_MIN,
	LIMB_MAX
}

const BIAS = 3

class Arm:
	var points: Array[Vector2] = []
	var desired: Vector2
	
	var step_start : Vector2
	var step_target : Vector2
	var step_time : float = 1
	
	var root_index: int
	var side : int
	var forward : float
	
	var phase : float
	var step_cooldown : float = 0.0

var spine: Array[Vector2] = []
var arms: Array[Arm] = []


func _ready():
	spine.clear()
	arms.clear()
	init_spine()
	init_arms()


func init_spine():
	spine.clear()
	var start := global_position
	for i in range(spine_segment_count):
		spine.append(start)

func init_arms():
	arms.clear()

	arms.append(create_arm(2, -2, -1.5, 0)) # Front left
	arms.append(create_arm(2, 2, -1.5, 0.5)) # Front right
	arms.append(create_arm(7, 2, -1.5, 0.5)) # Back left
	arms.append(create_arm(7, -2, -1.5, 0)) # Back right
	arms.append(create_arm(11, 2, -1.5, 0.5)) # Back left
	arms.append(create_arm(11, -2, -1.5, 0)) # Back right
	arms.append(create_arm(14, 2, -1.5, 0.5)) # Back left
	arms.append(create_arm(14, -2, -1.5, 0)) # Back right

func create_arm(root_index: int, side: int, forward: float, phase : float) -> Arm:
	var arm := Arm.new()
	arm.root_index = root_index
	arm.side = side
	arm.forward = forward
	arm.phase = phase
	
	var root_pos := spine[root_index]
	for i in range(arm_segment_count):
		arm.points.append(root_pos)

	arm.desired = root_pos
	return arm


func _process(delta):
	update_spine(target_auto.global_position, delta)

	for arm in arms:
		var new_target := compute_desired_pos(arm)
		
		if arm.step_time >= 1.0 and arm.desired.distance_to(new_target) > arm_max_distance:
			start_step(arm, new_target)
		
		update_step(arm, delta)
		fabrik_arm(arm.points, arm.desired, spine[arm.root_index])
		
		#update_arm_target(arm)
		#solve_arm(arm)
		
	queue_redraw()

func compute_desired_pos(arm: Arm) -> Vector2:
	var root := spine[arm.root_index]
	var spine_dir := get_spine_direction(arm.root_index)
	var side_dir := Vector2(-spine_dir.y, spine_dir.x) * arm.side

	return root + spine_dir * 30.0 * arm.forward + side_dir * 25.0

func start_step(arm: Arm, new_target: Vector2):
	if arm.step_time < 1.0:
		return
	
	arm.step_start = arm.desired
	arm.step_target = new_target
	arm.step_time = 0.0

func update_step(arm: Arm, delta: float):
	if arm.step_time < 1.0:
		arm.step_time += delta * 10
		arm.step_time = min(arm.step_time, 1.0)
		arm.desired = arm.step_start.lerp(arm.step_target, arm.step_time * 1.2)

func get_spine_direction(index: int) -> Vector2:
	if index == 0:
		return (spine[1] - spine[0]).normalized()
	return (spine[index] - spine[index - 1]).normalized()

func update_spine(target: Vector2, delta: float):
	spine[0] = spine[0].lerp(target, head_follow_speed * delta)

	for i in range(1, spine.size()):
		var dir := (spine[i] - spine[i - 1]).normalized()
		spine[i] = spine[i - 1] + dir * spine_segment_length

func update_arm_target(arm: Arm):
	var root_pos = spine[arm.root_index]

	var spine_dir := get_spine_direction(arm.root_index)
	var side_dir  := Vector2(-spine_dir.y, spine_dir.x) * arm.side
	
	var forward_offset : float = 50.0
	var side_offset : float = 25.0
	
	var desired_pos = root_pos + spine_dir * forward_offset * arm.forward + side_dir * side_offset
	
	if arm.desired.distance_to(spine[arm.root_index]) < arm_segment_length * 5:
		print("did do")
		arm.desired = desired_pos
	
	if arm.desired.distance_to(desired_pos) > arm_max_distance * 1.1:
		arm.desired = desired_pos


func solve_arm(arm: Arm):
	fabrik_arm(arm.points, arm.desired, spine[arm.root_index])


func fabrik_arm(points: Array[Vector2], target: Vector2, root: Vector2):
	var count := points.size()

	# Forward pass (end effector -> root)
	points[count - 1] = target
	for i in range(count - 2, -1, -1):
		var dir := (points[i] - points[i + 1]).normalized()
		points[i] = points[i + 1] + dir * arm_segment_length

	# Backward pass (root -> end effector)
	points[0] = root
	for i in range(1, count):
		var dir := (points[i] - points[i - 1]).normalized()
		points[i] = points[i - 1] + dir * arm_segment_length


func _draw():
	# Draw spine
	for i in range(spine.size() - 1):
		draw_line(spine[i], spine[i + 1], Color.GREEN, 3)

	# Draw arms
	for arm in arms:
		for i in range(arm.points.size() - 1):
			draw_line(arm.points[i], arm.points[i + 1], Color.ORANGE, 3)

		# Desired foot target
		draw_circle(arm.desired, 4, Color.RED)

	
	draw_circle(spine[0], 15, Color.RED)
