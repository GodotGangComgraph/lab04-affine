extends Control

@onready var check_left_right_btn: Button = $VBoxContainer/MarginContainer/MenuPanel/CheckLeftRight
@onready var check_polygon: Button = $VBoxContainer/MarginContainer/MenuPanel/CheckPolygon
@onready var draw_polygon_button: CheckBox = $VBoxContainer/MarginContainer/MenuPanel/DrawPolygon

@onready var dx: LineEdit = $VBoxContainer/MarginContainer/MenuPanel/Translation/Dx
@onready var dy: LineEdit = $VBoxContainer/MarginContainer/MenuPanel/Translation/Dy

@onready var rot: LineEdit = $VBoxContainer/MarginContainer/MenuPanel/Rotation/Rotation/Rot
@onready var point_rot_x: LineEdit = $VBoxContainer/MarginContainer/MenuPanel/Rotation/HBoxContainer/X
@onready var point_rot_y: LineEdit = $VBoxContainer/MarginContainer/MenuPanel/Rotation/HBoxContainer/Y

@onready var sc_x: LineEdit = $VBoxContainer/MarginContainer/MenuPanel/Scale/Scale/ScX
@onready var sc_y: LineEdit = $VBoxContainer/MarginContainer/MenuPanel/Scale/Scale/ScY
@onready var point_sc_x: LineEdit = $VBoxContainer/MarginContainer/MenuPanel/Scale/HBoxContainer/X
@onready var point_sc_y: LineEdit = $VBoxContainer/MarginContainer/MenuPanel/Scale/HBoxContainer/Y

@onready var point_rot: Label = $PointRot
@onready var point_sc: Label = $PointSc

@onready var checkbox_rot: CheckBox = $VBoxContainer/MarginContainer/MenuPanel/Rotation/HBoxContainer/PointRot
@onready var checkbox_sc: CheckBox = $VBoxContainer/MarginContainer/MenuPanel/Scale/HBoxContainer/PointSc

const FLOATING_TEXT = preload("res://floating_text.tscn")

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
				is_point_in_polygon(event.global_position)
			elif check_left_right_btn.button_pressed:
				check_left_right(event.global_position)
			elif checkbox_rot.button_pressed:
				point_rot.position = get_global_mouse_position()-point_rot.pivot_offset
				point_rot_x.text = str(point_rot.position.x - point_rot.pivot_offset.x)
				point_rot_y.text = str(point_rot.position.y - point_rot.pivot_offset.y)
			elif checkbox_sc.button_pressed:
				point_sc.position = get_global_mouse_position()-point_sc.pivot_offset
				point_sc_x.text = str(point_sc.position.x - point_sc.pivot_offset.x)
				point_sc_y.text = str(point_sc.position.y - point_sc.pivot_offset.y)


func _on_clear_pressed() -> void:
	polygon.clear()
	queue_redraw()


func is_point_in_polygon(point: Vector2):
	if polygon.size() < 3:
		return
	
	var intersects = 0
	var n = polygon.size()
	
	for i in range(n):
		var v1 = polygon[i]
		var v2 = polygon[(i + 1) % n]
		
		if (v1.y > point.y) != (v2.y > point.y):
			var intersection_x = v1.x + (point.y - v1.y) * (v2.x - v1.x) / (v2.y - v1.y)
			if point.x < intersection_x:
				intersects += 1
	
	var result = intersects % 2 == 1
	
	var floating_text = FLOATING_TEXT.instantiate()
	floating_text.text = str(result)
	floating_text.position = get_global_mouse_position()
	
	if result:
		floating_text.self_modulate = Color(255, 0, 0)
	else:
		floating_text.self_modulate = Color(0, 0, 255)
	
	add_child(floating_text)


func check_left_right(to_check: Vector2):
	if polygon.is_empty():
		return
	
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
	
	var floating_text = FLOATING_TEXT.instantiate()
	var result = "Left" if vecprod > 0 else "Right"
	floating_text.text = result
	floating_text.position = get_global_mouse_position()
	
	if result == "Left":
		floating_text.self_modulate = Color(255, 0, 0)
	else:
		floating_text.self_modulate = Color(0, 0, 255)
	
	add_child(floating_text)
	return result


func apply_translation(point):
	if dx.text == "" or dy.text == "":
		return point
		
	var T = DenseMatrix.identity(3)
	T.set_element(2, 0, float(dx.text))
	T.set_element(2, 1, float(dy.text))
	
	var V: DenseMatrix = DenseMatrix.from_packed_array([1, 1, 1], 1, 3)
	V.set_element(0, 0, point.x)
	V.set_element(0, 1, point.y)
	
	V = V.multiply_dense(T)
	
	return Vector2(V.get_element(0, 0), V.get_element(0, 1))

func apply_scale(point):
	if sc_x.text == "" or sc_y.text == "":
		return point
	
	var T = DenseMatrix.identity(3)
	T.set_element(0, 0, float(sc_x.text))
	T.set_element(1, 1, float(sc_y.text))
	T.set_element(2, 0, (1-float(sc_x.text))*(point_sc.position.x-point_sc.pivot_offset.x))
	T.set_element(2, 1, (1-float(sc_y.text))*(point_sc.position.y-point_sc.pivot_offset.y))
	
	var V: DenseMatrix = DenseMatrix.from_packed_array([1, 1, 1], 1, 3)
	V.set_element(0, 0, point.x)
	V.set_element(0, 1, point.y)
	
	V = V.multiply_dense(T)
	
	return Vector2(V.get_element(0, 0), V.get_element(0, 1))

func apply_rotation(point):
	if rot.text == "":
		return point
	
	var rot_deg = deg_to_rad(float(rot.text))
	var cos_r = cos(rot_deg)
	var sin_r = sin(rot_deg)
	
	var T = DenseMatrix.identity(3)
	T.set_element(0, 0, cos_r)
	T.set_element(0, 1, sin_r)
	T.set_element(1, 0, -sin_r)
	T.set_element(1, 1, cos_r)
	var a = point_rot.position.x-point_rot.pivot_offset.x
	var b = point_rot.position.y-point_rot.pivot_offset.y
	T.set_element(2, 0, -a*cos_r+b*sin_r+a)
	T.set_element(2, 1, -a*sin_r-b*cos_r+b)
	
	var V: DenseMatrix = DenseMatrix.from_packed_array([1, 1, 1], 1, 3)
	V.set_element(0, 0, point.x)
	V.set_element(0, 1, point.y)
	
	V = V.multiply_dense(T)
	
	return Vector2(V.get_element(0, 0), V.get_element(0, 1))

func _on_apply_pressed() -> void:
	for i in range(polygon.size()):
		polygon[i] = apply_scale(polygon[i])
		polygon[i] = apply_translation(polygon[i])
		polygon[i] = apply_rotation(polygon[i])
	
	queue_redraw()


func _on_center_rot_pressed() -> void:
	if polygon.is_empty():
		return
	
	var x_min = 100000
	var x_max = 0
	var y_min = 100000
	var y_max = 0
	
	for p in polygon:
		x_max = max(x_max, p.x)
		x_min = min(x_min, p.x)
		y_max = max(y_max, p.y)
		y_min = min(y_min, p.y)
	
	point_rot.position = Vector2((x_max + x_min)/2, (y_max + y_min)/2)-point_rot.pivot_offset
	point_rot_x.text = str(point_rot.position.x)
	point_rot_y.text = str(point_rot.position.y)

func _on_center_sc_pressed() -> void:
	if polygon.is_empty():
		return
	
	var x_min = 100000
	var x_max = 0
	var y_min = 100000
	var y_max = 0
	
	for p in polygon:
		x_max = max(x_max, p.x)
		x_min = min(x_min, p.x)
		y_max = max(y_max, p.y)
		y_min = min(y_min, p.y)
	
	point_sc.position = Vector2((x_max + x_min)/2, (y_max + y_min)/2)-point_sc.pivot_offset
	point_sc_x.text = str(point_sc.position.x)
	point_sc_y.text = str(point_sc.position.y)


func _on_rot_x_text_changed(new_text: String) -> void:
	point_rot.position = Vector2(float(new_text), point_rot.position.y)


func _on_rot_y_text_changed(new_text: String) -> void:
	point_rot.position = Vector2(point_rot.position.x, float(new_text))


func _on_sc_x_text_changed(new_text: String) -> void:
	point_sc.position = Vector2(float(new_text), point_sc.position.y)


func _on_sc_y_text_changed(new_text: String) -> void:
	point_sc.position = Vector2(point_sc.position.x, float(new_text))
