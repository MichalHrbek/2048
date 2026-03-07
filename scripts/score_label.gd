extends Label

func _on_score_changed(new_score: int) -> void:
	text = str(new_score)
