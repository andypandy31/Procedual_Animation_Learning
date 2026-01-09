extends Node2D

@export var segment_count : int = 100
@export var segment_length : float = 5.0
@export var follow_speed : float = 10.0
@export var body_width := 10.0

var points : Array[Vector2] = []
var target : Vector2
var counter : int = 1
var root_position = Vector2(400, 300)


func _ready() -> void:
	for i in segment_count:
		points.append(global_position)

func _process(delta: float) -> void:
	var target = get_global_mouse_position()
	move_head(target, delta)
	resolve_chain()
	queue_redraw()

func move_head(target ,delta : float):
	points[0] = points[0].lerp(target, follow_speed * delta)


func resolve_chain():
	for i in range(1, points.size()):
		var dir = points[i] - points[i - 1]
		if dir.length() == 0:
			dir = Vector2.RIGHT
		dir = dir.normalized()
		points[i] = points[i - 1] + dir * segment_length

func _draw() -> void:
	for i in range(points.size() - 1):
		#draw_line(points[i], points[i + 1], Color.GREEN, 4.0)
		var angle = get_angle(i)
		var normal = Vector2(cos(angle + PI/2), sin(angle + PI/2))
		var width = body_width * (1.0 - float(i) / points.size())
		
		draw_line(
			points[i] + normal * width,
			points[i + 1] + normal * width,
			Color.RED,
			2.0
		)
		draw_line(
			points[i] - normal * width,
			points[i + 1] - normal * width,
			Color.GREEN,
			2.0
		)

func get_angle(i: int) -> float:
	if i == 0:
		return (points[1] - points[0]).angle()
	return (points[i] - points[i - 1]).angle()
