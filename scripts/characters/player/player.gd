extends CharacterBody2D


@export var player_name: String = "Reggie"
@export var health: int = 4
@export var shield: int = 2
@export var damage: int = 2
@onready var animated_sprite_2d_node: AnimatedSprite2D = $AnimatedSprite2D
@onready var key_picked_sprite_2d: Sprite2D = $PickedObjects/KeyPickedSprite2D
@onready var camera_2d: Camera2D = $Camera2D
@onready var stats_label: Label = $PocketVBoxContainer/StatsLabel
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D

var battle_room: Node2D

var last_world_position: Vector2 = Vector2.ZERO
var direction: Vector2 = Vector2.ZERO
var last_direction: Vector2 = Vector2.ZERO
var body_to_interact_with
var ladder_in_range: bool = false
var target_ladder: Area2D
var door_in_range: bool = false
var focused_door: Node2D
var connecting_door_endpoint: Vector2 = Vector2.ZERO
var key_is_equipped: bool = false
const SPEED = 100.0
const CLIMB_SPEED = 60
var shield_is_up: bool = false

enum state{STOPPED, IDLE, INTERACTING, CLIMBING_LADDER, USING_DOOR, BATTLE}
var current_state: state = state.STOPPED

func _ready() -> void:
	SignalHandler.slide_transition_completed.connect(_on_slide_transition_completed)
	SignalHandler.slide_transition_half_completed.connect(_on_slide_transition_half_completed)
	SignalHandler.preparing_to_go_for_battle.connect(_on_preparing_to_go_for_battle)
	SignalHandler.start_battle.connect(_on_start_battle)
	SignalHandler.end_dialogue.connect(_on_end_dialogue)
	SignalHandler.gather_battle_data.connect(_on_gather_battle_data)
	SignalHandler.finished_returning_from_battle.connect(_on_finished_returning_from_battle)
	SignalHandler.half_way_returning_from_battle.connect(_on_half_way_returning_from_battle)
	current_state = state.IDLE
	key_picked_sprite_2d.hide()
	set_player_name_globally()
	set_stats()
	hide_stats()

func set_player_name_globally() -> void:
	GameManager.set_player(self)

func _on_slide_transition_half_completed() -> void:
	link_door()

func _on_preparing_to_go_for_battle() -> void:
	prepare_for_battle()

func _on_slide_transition_completed() -> void:
	clear_using_door()

func _on_end_dialogue() -> void:
	if current_state == state.INTERACTING:
		current_state = state.IDLE
		hide_stats()

func _on_start_battle() -> void:
	go_for_battle()

func _on_gather_battle_data() -> void:
	camera_2d.enabled = false
	show_stats()

func _on_half_way_returning_from_battle() -> void:
	if current_state == state.BATTLE:
		self.global_position = last_world_position
		last_world_position = Vector2.ZERO
		camera_2d.enabled = true
		hide_stats()
		body_to_interact_with = null

func _on_finished_returning_from_battle() -> void:
	current_state = state.IDLE
	collision_shape_2d.set_deferred("disabled", false)

func _input(event: InputEvent) -> void:
	if current_state == state.IDLE:
		if event.is_action_pressed("interact") and body_to_interact_with:
			if body_to_interact_with.interact():
				current_state = state.INTERACTING

func _physics_process(_delta: float) -> void:
	if current_state == state.IDLE or current_state == state.CLIMBING_LADDER:
		direction = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
		direction.x = round(direction.x)
		direction.y = round(direction.y)
	else:
		direction = Vector2.ZERO
		set_current_animation(direction)
	handle_movement()
	handle_ladder_use()
	handle_door_use()
	move_and_slide()

func handle_movement():
	if current_state == state.IDLE:
		if direction.length() > 0:
			last_direction = direction
			velocity = direction * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
			velocity.y = move_toward(velocity.y, 0, SPEED)
		set_current_animation(direction)

func handle_ladder_use() -> void:
	if ladder_in_range:
		if current_state == state.IDLE:
			if direction.y != 0:
				current_state = state.CLIMBING_LADDER
				self.global_position.x = target_ladder.global_position.x
				self.set_collision_mask_value(2, false)
		elif current_state == state.CLIMBING_LADDER:
			if direction.y != 0:
				last_direction = Vector2(0, direction.y)
				velocity = Vector2(0, direction.y * CLIMB_SPEED)
				animated_sprite_2d_node.play("climb_ladder")
			else:
				velocity.x = 0
				velocity.y = move_toward(velocity.y, 0, CLIMB_SPEED)
				animated_sprite_2d_node.stop()

func handle_door_use() -> void:
	if door_in_range:
		if current_state == state.IDLE:
			if direction.y != 0:
				if focused_door.is_door_opened():
					current_state = state.USING_DOOR
					direction = Vector2.ZERO
					velocity = Vector2.ZERO
					set_current_animation(direction)
					SignalHandler.emit_player_using_door_signal(focused_door, self)
				else:
					if key_is_equipped and focused_door.open_door():
						drop_key()

func set_current_animation(dir: Vector2) -> void:
	if dir.length() == 0:
		if last_direction == Vector2(0,1):
			if animated_sprite_2d_node.animation != "idle_down":
				animated_sprite_2d_node.play("idle_down")
		elif last_direction == Vector2(0, -1):
			if animated_sprite_2d_node.animation != "idle_up":
				animated_sprite_2d_node.play("idle_up")
		elif last_direction == Vector2(1, 0) or last_direction == Vector2(1,1) or last_direction == Vector2(1,-1):
			if animated_sprite_2d_node.animation != "idle_right":
				animated_sprite_2d_node.play("idle_right")
		elif last_direction == Vector2(-1, 0) or last_direction == Vector2(-1,1) or last_direction == Vector2(-1,-1):
			if animated_sprite_2d_node.animation != "idle_left":
				animated_sprite_2d_node.play("idle_left")
		else:
			if animated_sprite_2d_node.animation != "idle_down":
				animated_sprite_2d_node.play("idle_down")
	else:
		if dir == Vector2(0,1):
			if animated_sprite_2d_node.animation != "run_down":
				animated_sprite_2d_node.play("run_down")
		elif dir == Vector2(0, -1):
			if animated_sprite_2d_node.animation != "run_up":
				animated_sprite_2d_node.play("run_up")
		elif dir == Vector2(1, 0) or dir == Vector2(1,1) or dir == Vector2(1,-1):
			if animated_sprite_2d_node.animation != "run_right":
				animated_sprite_2d_node.play("run_right")
		elif dir == Vector2(-1, 0) or dir == Vector2(-1,1) or dir == Vector2(-1,-1):
			if animated_sprite_2d_node.animation != "run_left":
				animated_sprite_2d_node.play("run_left")
		else:
			if animated_sprite_2d_node.animation != "idle_down":
				animated_sprite_2d_node.play("idle_down")

func set_body_to_interact_with(body) -> void:
	if body:
		body_to_interact_with = body
	else:
		body_to_interact_with = null

func set_ladder_in_range(condition: bool, ladder: Area2D) -> void:
	ladder_in_range = condition
	if not condition:
		if current_state == state.CLIMBING_LADDER:
			current_state = state.IDLE
			self.set_collision_mask_value(2, true)
			target_ladder = null
	else:
		target_ladder = ladder

func set_door_in_range(condition: bool, the_door: Node2D) -> void:
	door_in_range = condition
	if not condition:
		focused_door = null
	else:
		focused_door = the_door

func clear_using_door() -> void:
	if current_state == state.USING_DOOR:
		current_state = state.IDLE

func set_connecting_door_endpoint(door_endpoint: Vector2) -> void:
	connecting_door_endpoint = door_endpoint

func link_door() -> void:
	self.global_position = connecting_door_endpoint
	connecting_door_endpoint = Vector2.ZERO

func equip_key() -> bool:
	if not key_is_equipped:
		key_is_equipped = true
		key_picked_sprite_2d.show()
		return true
	return false

func drop_key() -> void:
	key_is_equipped = false
	key_picked_sprite_2d.hide()

func prepare_for_battle() -> void:
	current_state = state.STOPPED
	last_world_position = self.global_position
	collision_shape_2d.set_deferred("disabled", true)

func go_for_battle() ->  void:
	current_state = state.BATTLE

func set_battle_room(the_room: Node2D) -> void:
	battle_room = the_room

func attack() -> void:
	pass

func get_health() -> int:
	return health

func get_damage() -> int:
	return damage

func take_damage(value: int) -> void:
	if not shield_is_up:
		if health > 0:
			health -= value
			set_stats()

func defend() -> void:
	shield_is_up = true

func remove_shield() -> void:
	shield_is_up = false

func spare() -> void:
	pass

func show_stats() -> void:
	stats_label.show()

func hide_stats() -> void:
	stats_label.hide()

func set_stats() -> void:
	stats_label.text = "H: " + str(health) + " D: " + str(damage) + " S: " + str(shield)
