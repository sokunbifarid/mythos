extends Area2D

@onready var key_sprite_2d: Sprite2D = $KeySprite2D

var the_tween: Tween

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	the_tween = create_tween()
	the_tween.tween_property(key_sprite_2d, "position", Vector2(0,-10), 1)
	the_tween.tween_property(key_sprite_2d, "position", Vector2(0,-15), 1)
	the_tween.set_loops(0)


func _on_body_entered(body: Node2D) -> void:
	body.equip_key()
	self.set_deferred("monitoring", false)
	self.set_deferred("monitorable", false)
	self.hide()
	the_tween.kill()
