extends Node

signal slide_transition_half_completed
signal slide_transition_completed
signal player_using_door(the_door: Node2D, the_player: CharacterBody2D)
signal start_dialogue(npc: CharacterBody2D)
signal dialogue_option_selected(id: int)
signal end_dialogue
signal preparing_to_go_for_battle
signal gather_battle_data
signal start_battle
signal enable_player_battle_ui
signal player_selected_battle_option(id: int)
signal player_lost_battle
signal enemy_lost_battle
signal prepare_battle_fight
signal half_way_returning_from_battle
signal finished_returning_from_battle
signal dialogue_skipped
signal battle_spared
signal battle_room_initiator
signal set_damage_value

func emit_slide_transition_half_completed_signal() -> void:
	slide_transition_half_completed.emit()

func emit_slide_transition_completed_signal() -> void:
	slide_transition_completed.emit()

func emit_player_using_door_signal(the_door: Node2D, the_player: CharacterBody2D) -> void:
	player_using_door.emit(the_door, the_player)

func emit_start_dialogue_signal(npc: CharacterBody2D) -> void:
	start_dialogue.emit(npc)

func emit_end_dialogue_signal() -> void:
	end_dialogue.emit()

func emit_dialogue_option_selected_signal(id: int) -> void:
	dialogue_option_selected.emit(id)


func emit_preparing_to_go_for_battle_signal() -> void:
	preparing_to_go_for_battle.emit()

func emit_gather_battle_data_signal() -> void:
	gather_battle_data.emit()

func emit_start_battle_signal() -> void:
	start_battle.emit()

func emit_enable_player_battle_ui_signal() -> void:
	enable_player_battle_ui.emit()

func emit_player_selected_battle_option(id: int) -> void:
	player_selected_battle_option.emit(id)

func emit_player_lost_battle_signal() -> void:
	player_lost_battle.emit()

func emit_enemy_lost_battle_signal() -> void:
	enemy_lost_battle.emit()

func emit_prepare_battle_fight_signal() -> void:
	prepare_battle_fight.emit()

func emit_half_way_returning_from_battle_signal() -> void:
	half_way_returning_from_battle.emit()

func emit_finished_returning_from_battle_signal() -> void:
	finished_returning_from_battle.emit()

func emit_dialogue_skipped_signal() -> void:
	dialogue_skipped.emit()

func emit_battle_spared_signal() -> void:
	battle_spared.emit()

func emit_battle_room_initiator_signal() -> void:
	battle_room_initiator.emit()

#use this for the fight slider
func emit_set_damage_value_signal(value: int) -> void:
	set_damage_value.emit(value)
