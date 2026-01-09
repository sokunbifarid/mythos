extends CharacterBody2D

@onready var animated_sprite_2d_node: AnimatedSprite2D = $AnimatedSprite2D

var last_direction: Vector2 = Vector2.ZERO
const SPEED = 300.0
const JUMP_VELOCITY = -400.0


func _physics_process(delta: float) -> void:
	var direction : Vector2 = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	if direction.length() > 0:
		last_direction = direction
		velocity = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.y = move_toward(velocity.y, 0, SPEED)
	set_current_animation(direction)
	move_and_slide()

func set_current_animation(dir: Vector2) -> void:
	if dir.length() == 0:
		if last_direction.normalized() == Vector2(0,1):
			animated_sprite_2d_node.play("idle_down")
		elif last_direction.normalized() == Vector2(0, -1):
			animated_sprite_2d_node.play("idle_up")
		elif last_direction.normalized() == Vector2(1, 0) or last_direction.normalized() == Vector2(1,1) or last_direction.normalized() == Vector2(1,-1):
			animated_sprite_2d_node.play("idle_right")
		elif last_direction.normalized() == Vector2(-1, 0) or last_direction.normalized() == Vector2(-1,1) or last_direction.normalized() == Vector2(-1,-1):
			animated_sprite_2d_node.play("idle_left")
	else:
		if dir.normalized() == Vector2(0,1):
			animated_sprite_2d_node.play("run_down")
		elif dir.normalized() == Vector2(0, -1):
			animated_sprite_2d_node.play("run_up")
		elif dir.normalized() == Vector2(1, 0) or dir == Vector2(1,1) or dir == Vector2(1,-1):
			animated_sprite_2d_node.play("run_right")
		elif dir.normalized() == Vector2(-1, 0) or dir.normalized() == Vector2(-1,1) or dir.normalized() == Vector2(-1,-1):
			animated_sprite_2d_node.play("run_left")
