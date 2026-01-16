extends Node

var main_player: CharacterBody2D
var player_name: String = ""
var enemy_to_battle: CharacterBody2D

enum all_game_state{WORLD, BATTLE, RETURN_FROM_BATTLE}
var current_game_state: all_game_state = all_game_state.WORLD

enum character_battle_tasks{ATTACK, DEFEND, SPARE}

func _ready() -> void:
	SignalHandler.preparing_to_go_for_battle.connect(_on_preparing_to_go_for_battle)

func _on_preparing_to_go_for_battle() -> void:
	set_game_state_to_battle()

func set_game_state_to_world() -> void:
	current_game_state = all_game_state.WORLD

func set_game_state_to_battle() -> void:
	current_game_state = all_game_state.BATTLE

func is_world() -> bool:
	if current_game_state == all_game_state.WORLD:
		return true
	return false

func is_battle() -> bool:
	if current_game_state == all_game_state.BATTLE:
		return true
	return false

func is_return_from_battle() -> bool:
	if current_game_state == all_game_state.RETURN_FROM_BATTLE:
		return true
	return false

func set_player(the_player: CharacterBody2D) -> void:
	player_name = the_player.player_name
	main_player = the_player

func get_player_name() -> String:
	return player_name

func get_main_player() -> CharacterBody2D:
	if main_player:
		return main_player
	return null

func set_enemy_to_battle(the_enemy: CharacterBody2D) -> void:
	enemy_to_battle = the_enemy

func get_enemy_to_battle() -> CharacterBody2D:
	return enemy_to_battle
