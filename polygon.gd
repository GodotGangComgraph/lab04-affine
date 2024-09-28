extends Control

@onready var dx_selector: LineEdit = $VBoxContainer/MarginContainer/MenuPanel/DxSelector
@onready var dy_selector: LineEdit = $VBoxContainer/MarginContainer/MenuPanel/DySelector

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
