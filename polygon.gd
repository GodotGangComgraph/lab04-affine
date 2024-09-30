extends Control

@onready var check_left_right_btn: Button = $VBoxContainer/MarginContainer/MenuPanel/CheckLeftRight
@onready var check_polygon: Button = $VBoxContainer/MarginContainer/MenuPanel/CheckPolygon
@onready var dx_selector: LineEdit = $VBoxContainer/MarginContainer/MenuPanel/Translation/Dx
@onready var dy_selector: LineEdit = $VBoxContainer/MarginContainer/MenuPanel/Translation/Dy
@onready var draw_polygon_button: CheckBox = $VBoxContainer/MarginContainer/MenuPanel/DrawPolygon

const FLOATING_TEXT = preload("res://floating_text.tscn")

var T: DenseMatrix = DenseMatrix.identity(3)
var polygon: Array[Vector2]


func _draw() -> void:
	var color = Color.from_string("FCFAEE", Color.WHITE)
	if not polygon.is_empty():
		var first_point = polygon[0]
		var old_point = polygon[0]
		for point in polygon.slice(1, polygon.size()):
			draw_line(old_point, point, color, 2)
			old_point = point
		draw_line(old_point, first_point, color, 2)


func _on_panel_container_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == 1 and event.pressed:
			if draw_polygon_button.button_pressed:
				polygon.append(event.global_position)
				queue_redraw()
			elif check_polygon.button_pressed:
				print(is_point_in_polygon(event.global_position))
			elif check_left_right_btn.button_pressed:
				print(check_left_right(event.global_position))


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
	if polygon.size() < 3:
		return false
	
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
	if polygon.is_empty():
		return
	
	var old_point = polygon[0]
	var min_dist = 1e9 ; var min_edge = Vector2(0, 0)
	var a: Vector2
	var _b: Vector2
	for i in range(1, polygon.size() + 1):
		var point = polygon[i % polygon.size()]
		var edge: Vector2 = point - old_point
		var check_vec: Vector2 = old_point - to_check
		var dist = abs(check_vec.x * edge.y - check_vec.y * edge.x) / edge.length()
		if dist <= min_dist:
			min_dist = dist
			min_edge = edge
			a = old_point
			_b = point
		old_point = point
	var vecprod = (to_check - a).x * min_edge.y - (to_check - a).y * min_edge.x
	
	var floating_text = FLOATING_TEXT.instantiate()
	floating_text.text = "Left" if vecprod > 0 else "Right"
	floating_text.position = get_global_mouse_position()
	add_child(floating_text)
	return "Left" if vecprod > 0 else "Right"
