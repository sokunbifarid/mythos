extends CharacterBody2D

@export var npc_name: String = ""
@export var story_stage: int = 0
@export var health: int = 4
@export var shield: int = 2
@export var damage: int = 2
@onready var interact_label: Label = $PocketVBoxContainer/InteractLabel
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var stats_label: Label = $PocketVBoxContainer/StatsLabel
var battle_room: Node2D

enum all_states{STOPPED, IDLE, CHATTING, BATTLE}
var current_state: all_states = all_states.IDLE

var player_in_range = false
var shield_is_up: bool = false
var last_world_position: Vector2 = Vector2.ZERO

func _ready() -> void:
	randomize()
	SignalHandler.end_dialogue.connect(_on_end_dialogue)
	SignalHandler.preparing_to_go_for_battle.connect(_on_preparing_to_go_for_battle)
	SignalHandler.gather_battle_data.connect(_on_gather_battle_data)
	interact_label.hide()
	animated_sprite_2d.play("idle")
	hide_stats()

func _on_end_dialogue() -> void:
	current_state = all_states.IDLE

func _on_preparing_to_go_for_battle() -> void:
	current_state = all_states.STOPPED
	last_world_position = self.global_position

func _on_gather_battle_data() -> void:
	current_state = all_states.BATTLE
	show_stats()

func interact() -> bool:
	if current_state == all_states.IDLE:
		if DialogueManager.check_if_dialogue_is_present(npc_name, story_stage):
			SignalHandler.emit_start_dialogue_signal(self)
			current_state = all_states.CHATTING
			interact_label.hide()
			return true
	return false

func increase_story_stage() -> void:
	story_stage += 1

func get_npc_name() -> String:
	return npc_name

func get_story_stage() -> int:
	return story_stage

func set_battle_room(the_room: Node2D) -> void:
	battle_room = the_room

func _on_chat_detection_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		if current_state != all_states.CHATTING:
			player_in_range = true
			body.set_body_to_interact_with(self)
			interact_label.show()


func _on_chat_detection_area_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_in_range = false
		body.set_body_to_interact_with(null)
		interact_label.hide()

func get_health() -> int:
	return health

func get_damage() -> int:
	return damage

func attack() -> void:
	pass

func take_damage(value: int) -> void:
	if not shield_is_up:
		if health > 0:
			health -= value

func defend() -> void:
	shield_is_up = true

func remove_shield() -> void:
	shield_is_up = false

func allow_spare() -> bool:
	return true

func show_stats() -> void:
	stats_label.show()

func hide_stats() -> void:
	stats_label.hide()

func select_random_task() -> GameManager.character_battle_tasks:
	var random_selection: int = randi_range(0, GameManager.character_battle_tasks.size() - 2)
	if random_selection == 0:
		return GameManager.character_battle_tasks.ATTACK
	return GameManager.character_battle_tasks.DEFEND

func set_stats() -> void:
	stats_label.text = "H: " + str(health) + " D: " + str(damage) + " S: " + str(shield)
