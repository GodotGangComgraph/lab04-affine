extends Control

@onready var dx_selector: LineEdit = $VBoxContainer/MarginContainer/MenuPanel/DxSelector
@onready var dy_selector: LineEdit = $VBoxContainer/MarginContainer/MenuPanel/DySelector

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

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == 1:
			polygon.append(event.position)
			queue_redraw()
		

func _on_clear_pressed() -> void:
	polygon.clear()
	queue_redraw()

func affine_move(point, dx, dy):
	var T: DenseMatrix = DenseMatrix.identity(3)
	
func _on_move_pressed() -> void:
	if dx_selector.text == "" or dy_selector.text == "":
		return
	var dx = int(dx_selector.text)
	var dy = int(dx_selector.text)
	for i in range(polygon.size()):
		polygon[i] = affine_move(polygon[i], dx, dy)
