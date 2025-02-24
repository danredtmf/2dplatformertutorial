class_name Coin
extends RigidBody2D

@onready var _animation_player: AnimationPlayer = $AnimationPlayer
@onready var _interactive_area: InteractiveArea = $InteractiveArea

func _ready() -> void:
	_animation_player.play("show")
	gravity_scale = 0.0

func get_interactive() -> InteractiveArea:
	return _interactive_area

# Присоединить сигнал `tree_exited`
# От объекта `InteractiveArea`
# К родительскому объекту (`Coin`)
func _on_interactive_area_tree_exited() -> void:
	queue_free()

# Присоединить сигнал `animation_finished`
# От объекта `AnimationPlayer`
# К родительскому объекту (`Coin`)
func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "show":
		gravity_scale = 1.0

# Нужно привязать сигнал `_on_body_entered` у родительского объекта `Coin`
func _on_body_entered(body: Node) -> void:
	pass
