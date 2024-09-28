extends Control

@onready var dx_selector: LineEdit = $VBoxContainer/MarginContainer/MenuPanel/DxSelector
@onready var dy_selector: LineEdit = $VBoxContainer/MarginContainer/MenuPanel/DySelector
@onready var check_left_right_btn: Button = $VBoxContainer/MarginContainer/MenuPanel/CheckLeftRight
@onready var check_polygon: Button = $VBoxContainer/MarginContainer/MenuPanel/CheckPolygon

var T: DenseMatrix = DenseMatrix.identity(3)
var polygon: Array[Vector2]


func _draw() -> void:
	var color = Color.from_string("FCFAEE", Color.WHITE)
	if not polygon.is_empty():
		var first_point = polygon[0]
		var old_point = polygon[0]
		for point in polygon.slice(1, polygon.size()):
			draw_line(old_point, point, color)
			old_point = point
		draw_line(old_point, first_point, color)

func _on_panel_container_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == 1 and event.pressed:
			if check_polygon.button_pressed:
				print(is_point_in_polygon(event.global_position))
			if check_left_right_btn.button_pressed:
				print(check_left_right(event.global_position))
			else:
				polygon.append(event.global_position)
				queue_redraw()
				


func _on_clear_pressed() -> void:
	polygon.clear()
	queue_redraw()

func affine_move(point, dx, dy):
	T.set_element(2, 0, dx)
	T.set_element(2, 1, dy)
	
	var V: DenseMatrix = DenseMatrix.from_packed_array([1, 1, 1], 1, 3)
	V.set_element(0, 0, point.x)
	V.set_element(0, 1, point.y)
	
	V = V.multiply_dense(T)
	
	return Vector2(V.get_element(0, 0), V.get_element(0, 1))

func _on_move_pressed() -> void:
	if dx_selector.text == "" or dy_selector.text == "":
		return
	
	var dx = float(dx_selector.text)
	var dy = float(dx_selector.text)
	for i in range(polygon.size()):
		polygon[i] = affine_move(polygon[i], dx, dy)
	
	queue_redraw()
	
func is_point_in_polygon(point: Vector2) -> bool:
	var intersects = 0
	var n = polygon.size()
	
	for i in range(n):
		var v1 = polygon[i]
		var v2 = polygon[(i + 1) % n]
		
		# Проверяем, пересекает ли луч, выходящий вправо от точки, сторону полигона
		if (v1.y > point.y) != (v2.y > point.y):  # Точка между y координатами вершины
			var intersection_x = v1.x + (point.y - v1.y) * (v2.x - v1.x) / (v2.y - v1.y)
			if point.x < intersection_x:
				intersects += 1

	return intersects % 2 == 1  # Нечетное количество пересечений — точка внутри

func check_left_right(to_check: Vector2):
	var old_point = polygon[0]
	var min_dist = 1e9 ; var min_edge = Vector2(0, 0)
	var a: Vector2
	var b: Vector2
	for i in range(1, polygon.size() + 1):
		var point = polygon[i % polygon.size()]
		var edge: Vector2 = point - old_point
		var check_vec: Vector2 = old_point - to_check
		var dist = abs(check_vec.x * edge.y - check_vec.y * edge.x) / edge.length()
		if dist <= min_dist:
			min_dist = dist
			min_edge = edge
			a = old_point
			b = point
		old_point = point
	var vecprod = (to_check - a).x * min_edge.y - (to_check - a).y * min_edge.x
	#return [a, b]
	return "Left" if vecprod > 0 else "Right"
	

func _on_check_pressed() -> void:
	pass # Replace with function body.
