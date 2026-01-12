extends Node2D

@export var current_door_type: door_type = door_type.OPENED

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var static_body_collision_shape_2d: CollisionShape2D = $StaticBody2D/StaticBodyCollisionShape2D

enum door_type{OPENED, CLOSED}
var door_opened: bool = false
var door_can_be_opened: bool = false

func _ready() -> void:
	if current_door_type == door_type.OPENED:
		animation_player.play("open_door")
		door_opened = true
		static_body_collision_shape_2d.disabled = true
	elif current_door_type == door_type.CLOSED:
		animation_player.play("closed_door")
		door_opened = false
		door_can_be_opened = true
		static_body_collision_shape_2d.disabled = false

func _on_area_2d_body_entered(body: Node2D) -> void:
	body.set_door_in_range(true, self)

func _on_area_2d_body_exited(body: Node2D) -> void:
	body.set_door_in_range(false, self)

func is_door_opened() -> bool:
	return door_opened

func open_door() -> bool:
	if not door_can_be_opened:
		return false
	animation_player.play("opening_door")
	door_can_be_opened = false
	return true

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "opening_door":
		door_opened = true
		static_body_collision_shape_2d.set_deferred("disabled", true)
