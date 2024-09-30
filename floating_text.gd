extends Label

@onready var floating_text: Label = $"."


func _ready() -> void:
	var tween = get_tree().create_tween()
	
	tween.tween_property(floating_text, "modulate", Color.RED, 1)
	tween.tween_property(floating_text, "position", floating_text.position+Vector2(0, 100), 1)
	tween.tween_callback(floating_text.queue_free)
	
	tween.tween_callback(floating_text.queue_free).set_delay(2)
