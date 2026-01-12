extends Node

signal slide_transition_half_completed
signal slide_transition_completed
signal player_using_door(the_door: Node2D, the_player: CharacterBody2D)

func emit_slide_transition_half_completed() -> void:
	slide_transition_half_completed.emit()

func emit_slide_transition_completed() -> void:
	slide_transition_completed.emit()

func emit_player_using_door_signal(the_door: Node2D, the_player: CharacterBody2D) -> void:
	player_using_door.emit(the_door, the_player)
