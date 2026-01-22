extends Node2D

@onready var camera_2d: Camera2D = $Camera2D
@onready var player_foot_mark_sprite_2d: Sprite2D = $Characters/Player/PlayerFootMarkSprite2D
@onready var enemy_foot_mark_sprite_2d_2: Sprite2D = $Characters/Enemy/EnemyFootMarkSprite2D2
@onready var battle_loop_timer: Timer = $BattleLoopTimer
var the_tween: Tween

const FIRST_DELAY_ON_BATTLE_START: float = 0.5

enum room_state{OPTIONS_SELECTION, DELAY, TALKING, PLAYER_SELECT_TASK, ENEMY_SELECT_TASK, CHALLENGE, PLAYER_CHALLENGE, ENEMY_CHALLENGE, PLAYER_LOST, ENEMY_LOST, SPARE}
var current_room_state: room_state = room_state.OPTIONS_SELECTION

var player_character_task: GameManager.character_battle_tasks = GameManager.character_battle_tasks.ATTACK
var enemy_character_task: GameManager.character_battle_tasks = GameManager.character_battle_tasks.ATTACK

var player_waiting_to_attack: bool = false
var enemy_waiting_to_attack: bool = false

func _ready() -> void:
	SignalHandler.gather_battle_data.connect(_on_gather_battle_data)
	SignalHandler.player_selected_battle_option.connect(_on_player_selected_battle_option)
	SignalHandler.half_way_returning_from_battle.connect(_on_half_way_returning_from_battle)
	SignalHandler.battle_room_initiator.connect(_on_battle_room_initiator)
	disable_battle_stage()

func _on_gather_battle_data() -> void:
	enable_battle_stage()

func _on_player_selected_battle_option(id: int) -> void:
	match id:
		GameManager.character_battle_tasks.ATTACK:
			current_room_state = room_state.PLAYER_SELECT_TASK
			player_character_task = GameManager.character_battle_tasks.ATTACK
			GameManager.get_main_player().attack()
		GameManager.character_battle_tasks.DEFEND:
			current_room_state = room_state.PLAYER_SELECT_TASK
			player_character_task = GameManager.character_battle_tasks.DEFEND
			GameManager.get_main_player().defend()
		GameManager.character_battle_tasks.SPARE:
			current_room_state = room_state.SPARE
			GameManager.current_game_state = GameManager.all_game_state.SPARED_FROM_BATTLE
			SignalHandler.emit_battle_spared_signal()
		GameManager.character_battle_tasks.TALK:
			current_room_state = room_state.TALKING
	launch_timer(FIRST_DELAY_ON_BATTLE_START)

func _on_half_way_returning_from_battle() -> void:
	disable_battle_stage()

func _on_battle_room_initiator() -> void:
	enable_battle_stage()

func enable_battle_stage() -> void:
	if camera_2d.enabled == false:
		camera_2d.enabled = true
	GameManager.get_main_player().set_battle_scale()
	if GameManager.get_main_player().global_position != player_foot_mark_sprite_2d.global_position - Vector2(0, 5):
		GameManager.get_main_player().global_position = player_foot_mark_sprite_2d.global_position - Vector2(0, 5)
	if GameManager.get_enemy_to_battle().global_position != enemy_foot_mark_sprite_2d_2.global_position + Vector2(0, 5):
		GameManager.get_enemy_to_battle().global_position = enemy_foot_mark_sprite_2d_2.global_position + Vector2(0, 5)
	GameManager.get_main_player().set_battle_room(self)
	GameManager.get_enemy_to_battle().set_battle_room(self)
	#battle_loop()
	current_room_state = room_state.OPTIONS_SELECTION
	launch_timer(FIRST_DELAY_ON_BATTLE_START)

func open_options_selection() -> void:
	SignalHandler.emit_enable_player_battle_ui_signal()

func disable_battle_stage() -> void:
	camera_2d.enabled = false
	if the_tween:
		the_tween.kill()

func get_player_transition_attack_point() -> Vector2:
	var return_value: Vector2 = Vector2.ZERO
	return return_value

func get_enemy_transition_attack_point() -> Vector2:
	var return_value: Vector2 = Vector2.ZERO
	return return_value

func start_new_round() -> void:
	GameManager.get_main_player().remove_shield()
	GameManager.get_enemy_to_battle().remove_shield()

func launch_timer(the_delay: float) -> void:
	battle_loop_timer.wait_time = the_delay
	battle_loop_timer.start()

func allow_player_select_task() -> void:
	current_room_state = room_state.PLAYER_SELECT_TASK
	#SignalHandler.emit_enable_player_battle_ui_signal()

func allow_enemy_select_task() -> void:
	current_room_state = room_state.ENEMY_SELECT_TASK
	enemy_character_task = GameManager.get_enemy_to_battle().select_random_task()
	if enemy_character_task == GameManager.character_battle_tasks.ATTACK:
		GameManager.get_enemy_to_battle().attack()
	elif enemy_character_task == GameManager.character_battle_tasks.DEFEND:
		GameManager.get_enemy_to_battle().defend()
	launch_timer(FIRST_DELAY_ON_BATTLE_START)

func prepare_to_fight() -> void:
	current_room_state = room_state.CHALLENGE
	SignalHandler.emit_prepare_battle_fight_signal()
	launch_timer(FIRST_DELAY_ON_BATTLE_START)

func player_performs_task() -> void:
	current_room_state = room_state.PLAYER_CHALLENGE
	if player_character_task == GameManager.character_battle_tasks.ATTACK:
		player_waiting_to_attack = true
		GameManager.get_main_player().play_attack_effect()
		tween_character_for_attack()
	elif player_character_task == GameManager.character_battle_tasks.DEFEND:
		launch_timer(FIRST_DELAY_ON_BATTLE_START)

func enemy_performs_task() -> void:
	current_room_state = room_state.ENEMY_CHALLENGE
	if enemy_character_task == GameManager.character_battle_tasks.ATTACK:
		enemy_waiting_to_attack = true
		tween_enemy_for_attack()
	elif enemy_character_task == GameManager.character_battle_tasks.DEFEND:
		
		launch_timer(FIRST_DELAY_ON_BATTLE_START)

func check_enemy_stats() -> void:
	if check_enemy_health():
		launch_timer(FIRST_DELAY_ON_BATTLE_START)
	else:
		current_room_state = room_state.ENEMY_LOST
		launch_timer(FIRST_DELAY_ON_BATTLE_START)

func check_player_stats() -> void:
	if check_player_health():
		launch_timer(FIRST_DELAY_ON_BATTLE_START)
	else:
		current_room_state = room_state.PLAYER_LOST
		launch_timer(FIRST_DELAY_ON_BATTLE_START)

func tween_character_for_attack() -> void:
	const DURATION: float = 0.25
	if the_tween:
		the_tween.kill()
	the_tween = create_tween()
	the_tween.tween_property(GameManager.get_main_player(), "scale", Vector2(1.1,1.1), DURATION)
	the_tween.finished.connect(_on_the_tween_completed)

func tween_player_to_reset_position() -> void:
	const DURATION: float = 0.25
	if the_tween:
		the_tween.kill()
	the_tween = create_tween()
	the_tween.tween_property(GameManager.get_main_player(), "scale", Vector2(1,1), DURATION)
	the_tween.finished.connect(_on_the_tween_completed)

func tween_enemy_for_attack() -> void:
	const DURATION: float = 0.25
	if the_tween:
		the_tween.kill()
	the_tween = create_tween()
	the_tween.tween_property(GameManager.get_enemy_to_battle(), "scale", Vector2(1.1,1.1), DURATION)
	the_tween.finished.connect(_on_the_tween_completed)

func tween_enemy_to_reset_position() -> void:
	const DURATION: float = 0.25
	if the_tween:
		the_tween.kill()
	the_tween = create_tween()
	the_tween.tween_property(GameManager.get_enemy_to_battle(), "scale", Vector2(1,1), DURATION)
	the_tween.finished.connect(_on_the_tween_completed)

func _on_the_tween_completed() -> void:
	if current_room_state == room_state.PLAYER_CHALLENGE:
		if player_waiting_to_attack:
			player_waiting_to_attack = false
			tween_player_to_reset_position()
			GameManager.get_enemy_to_battle().take_damage(GameManager.get_main_player().get_damage())
		else:
			check_enemy_stats()
	elif current_room_state == room_state.ENEMY_CHALLENGE:
		if enemy_waiting_to_attack:
			tween_enemy_to_reset_position()
			enemy_waiting_to_attack = false
			GameManager.get_main_player().take_damage(GameManager.get_enemy_to_battle().get_damage())
		else:
			check_player_stats()

func check_enemy_health() -> bool:
	if GameManager.get_enemy_to_battle().get_health() > 0:
		return true
	return false

func check_player_health() -> bool:
	if GameManager.get_main_player().get_health() > 0:
		return true
	return false

func battle_loop() -> void:
	GameManager.get_main_player().remove_shield()
	GameManager.get_enemy_to_battle().remove_shield()
	current_room_state = room_state.DELAY
	launch_timer(FIRST_DELAY_ON_BATTLE_START)

func _on_battle_loop_timer_timeout() -> void:
	if current_room_state == room_state.OPTIONS_SELECTION:
		open_options_selection()
	if current_room_state == room_state.DELAY:
		open_options_selection()
		#allow_player_select_task()
	elif current_room_state == room_state.PLAYER_SELECT_TASK:
		allow_enemy_select_task()
	elif current_room_state == room_state.ENEMY_SELECT_TASK:
		prepare_to_fight()
	elif current_room_state == room_state.CHALLENGE:
		player_performs_task()
	elif current_room_state == room_state.PLAYER_CHALLENGE:
		enemy_performs_task()
	elif current_room_state == room_state.ENEMY_CHALLENGE:
		battle_loop()
	elif current_room_state == room_state.TALKING:
		GameManager.get_enemy_to_battle().chat()
	elif current_room_state == room_state.PLAYER_LOST:
		GameManager.current_game_state = GameManager.all_game_state.RETURN_FROM_BATTLE
		SignalHandler.emit_player_lost_battle_signal()
	elif current_room_state == room_state.ENEMY_LOST:
		GameManager.current_game_state = GameManager.all_game_state.RETURN_FROM_BATTLE
		SignalHandler.emit_enemy_lost_battle_signal()
