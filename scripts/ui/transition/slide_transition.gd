extends Control

@onready var animation_player: AnimationPlayer = $AnimationPlayer
var slide_in_animation_half_way: bool = false
var player_using_door: bool = false

func _ready() -> void:
	SignalHandler.player_using_door.connect(_on_player_using_door)
	SignalHandler.preparing_to_go_for_battle.connect(_on_preparing_to_go_for_battle)

func _on_player_using_door(_the_door: Node2D, _the_player: CharacterBody2D) -> void:
	animation_player.play("slide_in")
	player_using_door = true

func _on_preparing_to_go_for_battle() -> void:
	await get_tree().create_timer(1.0).timeout
	animation_player.play("slide_in")

func _process(_delta: float) -> void:
	if GameManager.is_world() and player_using_door:
		if animation_player.current_animation == "slide_in":
			if not slide_in_animation_half_way:
				if animation_player.current_animation_position > animation_player.current_animation_length / 2:
					slide_in_animation_half_way = true
					SignalHandler.emit_slide_transition_half_completed_signal()
	elif GameManager.is_battle():
		if animation_player.current_animation == "slide_in":
			if not slide_in_animation_half_way:
				if animation_player.current_animation_position > animation_player.current_animation_length / 2:
					slide_in_animation_half_way = true
					SignalHandler.emit_gather_battle_data_signal()

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if GameManager.is_world() and player_using_door:
		if anim_name == "slide_in":
			animation_player.play("slide_out")
			slide_in_animation_half_way = false
		elif anim_name == "slide_out":
			player_using_door = false
			SignalHandler.emit_slide_transition_completed_signal()

	elif GameManager.is_battle():
		if anim_name == "slide_in":
			animation_player.play("slide_out")
			slide_in_animation_half_way = false
		elif anim_name == "slide_out":
			SignalHandler.emit_start_battle_signal()
