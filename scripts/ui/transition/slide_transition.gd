extends Control

@onready var animation_player: AnimationPlayer = $AnimationPlayer
var slide_in_animation_half_way: bool = false

func _ready() -> void:
	SignalHandler.player_using_door.connect(_on_player_using_door)

func _on_player_using_door(_the_door: Node2D, _the_player: CharacterBody2D) -> void:
	animation_player.play("slide_in")

func _process(_delta: float) -> void:
	if animation_player.current_animation == "slide_in":
		if not slide_in_animation_half_way:
			if animation_player.current_animation_position > animation_player.current_animation_length / 2:
				slide_in_animation_half_way = true
				SignalHandler.emit_slide_transition_half_completed()

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "slide_in":
		animation_player.play("slide_out")
		slide_in_animation_half_way = false
	elif anim_name == "slide_out":
		SignalHandler.emit_slide_transition_completed()
