extends Control

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
