extends LineEdit

var value : float = 0.0

func _on_text_changed(new_text: String) -> void:
	if new_text.is_valid_float():
		value = float(new_text)
	elif new_text == "":
		self.text = ""
		value = 0
	else:
		var col = self.caret_column
		self.text = str(value)
		self.caret_column = col-1
