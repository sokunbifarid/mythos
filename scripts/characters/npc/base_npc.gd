extends CharacterBody2D

@export var npc_name: String = ""
@export var story_stage: int = 0
@export var health: int = 4
@export var shield: int = 2
@export var damage: int = 2
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var chat_detection_collision_shape_2d: CollisionShape2D = $chat_detection_area/CollisionShape2D
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var damage_label: Label = $NpcData/DamageLabel
@onready var interact_label: Label = $NpcData/PocketVBoxContainer/InteractLabel
@onready var battle_action_label: Label = $NpcData/PocketVBoxContainer/BattleActionLabel
@onready var stats_label: Label = $NpcData/PocketVBoxContainer/StatsLabel

var battle_room: Node2D
var the_tween: Tween

enum all_states{STOPPED, IDLE, CHATTING, BATTLE}
var current_state: all_states = all_states.IDLE

var default_health_value: int
var player_in_range = false
var shield_is_up: bool = false
var last_world_position: Vector2 = Vector2.ZERO

func _ready() -> void:
	randomize()
	SignalHandler.end_dialogue.connect(_on_end_dialogue)
	SignalHandler.preparing_to_go_for_battle.connect(_on_preparing_to_go_for_battle)
	SignalHandler.gather_battle_data.connect(_on_gather_battle_data)
	SignalHandler.half_way_returning_from_battle.connect(_on_half_way_returning_from_battle)
	SignalHandler.finished_returning_from_battle.connect(_on_finished_returning_from_battle)
	default_health_value = health
	interact_label.hide()
	animated_sprite_2d.play("idle")
	hide_stats()

func _on_end_dialogue() -> void:
	#currwent_state = all_states.IDLE
	pass

func _on_preparing_to_go_for_battle() -> void:
	current_state = all_states.STOPPED
	last_world_position = self.global_position
	chat_detection_collision_shape_2d.set_deferred("disabled", true)
	collision_shape_2d.set_deferred("disabled", true)
	health = default_health_value
	set_stats()

func _on_gather_battle_data() -> void:
	current_state = all_states.BATTLE
	show_stats()

func _on_half_way_returning_from_battle() -> void:
	hide_stats()
	if self.global_position != last_world_position:
		self.global_position = last_world_position
		last_world_position = Vector2.ZERO
		interact_label.hide()
		self.scale = Vector2(1,1)

func _on_finished_returning_from_battle() -> void:
	current_state = all_states.IDLE
	chat_detection_collision_shape_2d.set_deferred("disabled", false)
	collision_shape_2d.set_deferred("disabled", false)

func interact() -> bool:
	if current_state == all_states.IDLE:
		current_state = all_states.BATTLE
		GameManager.set_enemy_to_battle(self)
		SignalHandler.emit_preparing_to_go_for_battle_signal()
		return true
	return false

func chat() -> void:
	if DialogueManager.check_if_dialogue_is_present(npc_name, story_stage):
		SignalHandler.emit_start_dialogue_signal(self)
		current_state = all_states.CHATTING
		interact_label.hide()

func increase_story_stage() -> void:
	story_stage += 1

func get_npc_name() -> String:
	return npc_name

func get_story_stage() -> int:
	return story_stage

func set_battle_room(the_room: Node2D) -> void:
	if not battle_room:
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
	battle_action_label.show()
	battle_action_label.text = "ATTACKING"

func take_damage(value: int) -> void:
	if not shield_is_up:
		if health > 0:
			health -= value
			health = clampi(health, 0, default_health_value)
			tween_damage_label(value)
			set_stats()
	else:
		tween_damage_label(0)

func defend() -> void:
	shield_is_up = true
	battle_action_label.show()
	battle_action_label.text = "DEFENDING"

func remove_shield() -> void:
	shield_is_up = false
	battle_action_label.hide()

func allow_spare() -> bool:
	return true

func show_stats() -> void:
	stats_label.show()

func hide_stats() -> void:
	stats_label.hide()
	battle_action_label.hide()
	damage_label.hide()

func select_random_task() -> GameManager.character_battle_tasks:
	var random_selection: int = randi_range(0, 10)
	if random_selection <= 6:
		return GameManager.character_battle_tasks.ATTACK
	return GameManager.character_battle_tasks.DEFEND

func set_stats() -> void:
	stats_label.text = "H: " + str(health) + " D: " + str(damage) + " S: " + str(shield)

func tween_damage_label(value: int) -> void:
	damage_label.show()
	const DURATION: float = 0.6
	if value >= 4:
		damage_label.text = "-" + str(value) + " CRITICAL"
	else:
		damage_label.text = "-" + str(value)
	damage_label.position = Vector2(0, 32)
	damage_label.self_modulate = Color(1,1,1,1)
	if the_tween:
		the_tween.kill()
	the_tween = create_tween()
	the_tween.tween_property(damage_label, "position", Vector2(0, 8), DURATION)
	the_tween.tween_property(damage_label, "self_modulate", Color(1,1,1,0), DURATION / 2)
	the_tween.finished.connect(_on_the_tween_finished)

func _on_the_tween_finished() -> void:
	if damage_label.visible:
		damage_label.hide()
