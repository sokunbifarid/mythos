extends Area2D


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		body.set_ladder_in_range(true, self)


func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		body.set_ladder_in_range(false, self)
