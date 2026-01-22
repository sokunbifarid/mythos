extends Control

@onready var battle_margin_container: Panel = $HUDPopups/BattleMarginContainer
@onready var player_input_panel: Panel = $BattleUI/PlayerInputPanel
@onready var battle_result_panel: Panel = $BattleUI/BattleResultPanel
@onready var you_win_battle_result_label: Label = $BattleUI/BattleResultPanel/YouWinBattleResultLabel
@onready var you_lost_battle_result_label: Label = $BattleUI/BattleResultPanel/YouLostBattleResultLabel
@onready var attack_button: Button = $BattleUI/PlayerInputPanel/VBoxContainer/BattleUIGridContainer/AttackButton
@onready var spared_battle_result_label: Label = $BattleUI/BattleResultPanel/SparedBattleResultLabel
@onready var damage_meter_panel: Panel = $BattleUI/DamageMeterPanel
@onready var damage_cursor_texture_rect: TextureRect = $BattleUI/DamageMeterPanel/DamageCursorTextureRect

var the_tween: Tween

func _ready() -> void:
	SignalHandler.preparing_to_go_for_battle.connect(_on_preparing_to_go_for_battle)
	SignalHandler.gather_battle_data.connect(_on_gather_battle_data)
	SignalHandler.enable_player_battle_ui.connect(_on_enable_player_battle_ui)
	SignalHandler.prepare_battle_fight.connect(_on_prepare_battle_fight)
	SignalHandler.player_lost_battle.connect(_on_player_lost_battle)
	SignalHandler.enemy_lost_battle.connect(_on_enemy_lost_battle)
	SignalHandler.half_way_returning_from_battle.connect(_on_half_way_returning_from_battle)
	SignalHandler.battle_spared.connect(_on_battle_spared)
	battle_margin_container.hide()
	player_input_panel.hide()
	hide_battle_result()

func _on_enable_player_battle_ui() -> void:
	player_input_panel.show()
	attack_button.grab_focus()

func _on_preparing_to_go_for_battle() -> void:
	#battle_margin_container.show()
	pass

func _on_gather_battle_data() -> void:
	battle_margin_container.hide()

func _on_attack_button_pressed() -> void:
	show_damage_meter()
	player_input_panel.hide()

func _on_defend_button_pressed() -> void:
	SignalHandler.emit_player_selected_battle_option(GameManager.character_battle_tasks.DEFEND)
	player_input_panel.hide()

func _on_talk_button_pressed() -> void:
	SignalHandler.emit_player_selected_battle_option(GameManager.character_battle_tasks.TALK)
	player_input_panel.hide()

func _on_spare_button_pressed() -> void:
	SignalHandler.emit_player_selected_battle_option(GameManager.character_battle_tasks.SPARE)
	player_input_panel.hide()

func _on_prepare_battle_fight() -> void:
	battle_margin_container.show()
	await get_tree().create_timer(0.5).timeout
	battle_margin_container.hide()

func _on_player_lost_battle() -> void:
	show_player_lost_battle_result()

func _on_enemy_lost_battle() -> void:
	show_player_win_battle_result()

func _on_half_way_returning_from_battle() -> void:
	hide_battle_result()

func _on_battle_spared() -> void:
	show_game_spared()

func _unhandled_input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("accept"):
		if damage_meter_panel.visible:
			stop_damage_meter()
			calculate_damage_value()
			damage_meter_panel.hide()
			SignalHandler.emit_player_selected_battle_option(GameManager.character_battle_tasks.ATTACK)

func hide_battle_result() -> void:
	battle_result_panel.hide()
	damage_meter_panel.hide()

func show_player_win_battle_result() -> void:
	battle_result_panel.show()
	you_win_battle_result_label.show()
	you_lost_battle_result_label.hide()
	spared_battle_result_label.hide()

func show_player_lost_battle_result() -> void:
	battle_result_panel.show()
	you_win_battle_result_label.hide()
	you_lost_battle_result_label.show()
	spared_battle_result_label.hide()

func show_game_spared() -> void:
	battle_result_panel.show()
	spared_battle_result_label.show()
	you_win_battle_result_label.hide()
	you_lost_battle_result_label.hide()

func calculate_damage_value() -> void:
	if damage_cursor_texture_rect.position.x > 370 and damage_cursor_texture_rect.position.x < 402:
		SignalHandler.emit_set_damage_value_signal(4)
	elif damage_cursor_texture_rect.position.x >= 402 and damage_cursor_texture_rect.position.x < 530:
		SignalHandler.emit_set_damage_value_signal(3)
	elif damage_cursor_texture_rect.position.x >= 530 and damage_cursor_texture_rect.position.x < 658:
		SignalHandler.emit_set_damage_value_signal(2)
	elif damage_cursor_texture_rect.position.x >= 658:
		SignalHandler.emit_set_damage_value_signal(1)
	elif damage_cursor_texture_rect.position.x <= 370 and damage_cursor_texture_rect.position.x > 250:
		SignalHandler.emit_set_damage_value_signal(3)
	elif damage_cursor_texture_rect.position.x <= 250 and damage_cursor_texture_rect.position.x > 106:
		SignalHandler.emit_set_damage_value_signal(2)
	elif damage_cursor_texture_rect.position.x <= 106:
		SignalHandler.emit_set_damage_value_signal(1)
	else:
		SignalHandler.emit_set_damage_value_signal(1)

func show_damage_meter() -> void:
	damage_meter_panel.show()
	var end_pos = damage_meter_panel.size.x - damage_cursor_texture_rect.size.x - damage_cursor_texture_rect.size.x / 2
	var start_pos: float = damage_cursor_texture_rect.size.x
	damage_cursor_texture_rect.position.x = 386.0
	var delay : float = 2.0
	if the_tween:
		the_tween.kill()
	the_tween = create_tween()
	the_tween.tween_property(damage_cursor_texture_rect, "position:x", end_pos, delay)
	the_tween.tween_property(damage_cursor_texture_rect, "position:x", start_pos, delay)
	the_tween.set_loops()

func stop_damage_meter() -> void:
	if the_tween:
		the_tween.kill()
