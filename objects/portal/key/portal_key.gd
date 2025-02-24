class_name PortalKey
extends RigidBody2D

@onready var _animation_player: AnimationPlayer = $AnimationPlayer
@onready var _interactive_area: InteractiveArea = $InteractiveArea

func _ready() -> void:
	_animation_player.play("show")

func get_interactive() -> InteractiveArea:
	return _interactive_area

# Присоединить сигнал `tree_exited`
# От объекта `InteractiveArea`
# К родительскому объекту (`PortalKey`)
func _on_interactive_area_tree_exited() -> void:
	queue_free()
