extends Control

@onready var battle_margin_container: Panel = $HUDPopups/BattleMarginContainer
@onready var player_input_panel: Panel = $BattleUI/PlayerInputPanel
@onready var battle_result_panel: Panel = $BattleUI/BattleResultPanel
@onready var you_win_battle_result_label: Label = $BattleUI/BattleResultPanel/YouWinBattleResultLabel
@onready var you_lost_battle_result_label: Label = $BattleUI/BattleResultPanel/YouLostBattleResultLabel

func _ready() -> void:
	SignalHandler.preparing_to_go_for_battle.connect(_on_preparing_to_go_for_battle)
	SignalHandler.gather_battle_data.connect(_on_gather_battle_data)
	SignalHandler.enable_player_battle_ui.connect(_on_enable_player_battle_ui)
	SignalHandler.prepare_battle_fight.connect(_on_prepare_battle_fight)
	SignalHandler.player_lost_battle.connect(_on_player_lost_battle)
	SignalHandler.enemy_lost_battle.connect(_on_enemy_lost_battle)
	battle_margin_container.hide()
	player_input_panel.hide()
	hide_battle_result()

func _on_enable_player_battle_ui() -> void:
	player_input_panel.show()

func _on_preparing_to_go_for_battle() -> void:
	battle_margin_container.show()

func _on_gather_battle_data() -> void:
	battle_margin_container.hide()

func _on_attack_button_pressed() -> void:
	SignalHandler.emit_player_selected_battle_option(GameManager.character_battle_tasks.ATTACK)
	player_input_panel.hide()

func _on_defend_button_pressed() -> void:
	SignalHandler.emit_player_selected_battle_option(GameManager.character_battle_tasks.DEFEND)
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

func hide_battle_result() -> void:
	battle_result_panel.hide()

func show_player_win_battle_result() -> void:
	battle_result_panel.show()
	you_win_battle_result_label.show()
	you_lost_battle_result_label.hide()

func show_player_lost_battle_result() -> void:
	battle_result_panel.show()
	you_win_battle_result_label.hide()
	you_lost_battle_result_label.show()
