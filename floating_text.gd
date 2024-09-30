extends Label

@onready var floating_text: Label = $"."


func _ready() -> void:
	var tween = get_tree().create_tween().set_parallel()
	
	tween.tween_property(floating_text, "self_modulate", Color(0, 255, 0, 0), 2)
	tween.tween_property(floating_text, "position", Vector2(0, -200), 2).as_relative()
	
	tween.tween_callback(floating_text.queue_free).set_delay(2)
