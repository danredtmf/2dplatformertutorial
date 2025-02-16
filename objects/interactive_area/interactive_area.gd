@tool
class_name InteractiveArea
extends Area2D

enum Type { ENTITY, TRIGGER }

@export var type: Type
@export var id: String
@export var ui_name: String
@export var ui_desc: String
@export var disabled: bool
@export var delete_after: bool
@export var is_trigger_entered := true
@export var is_trigger_exited: bool

@export var size := Vector2(20, 20)

@onready var _shape: CollisionShape2D = $Shape

func _ready() -> void:
	_shape.shape = _shape.shape.duplicate()
	_change_size()

func _change_size() -> void:
	_shape.shape.size = size

func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		_change_size()

func interact() -> void:
	EventBus.interactive_item_interacted.emit(self)
	if delete_after:
		queue_free()

# Не забудьте присоединить сигнал объекта `InteractiveArea`
func _on_body_entered(body: Node2D) -> void:
	if type == Type.TRIGGER and body is Player\
	and not disabled and is_trigger_entered:
		interact()

# Не забудьте присоединить сигнал объекта `InteractiveArea`
func _on_body_exited(body: Node2D) -> void:
	if type == Type.TRIGGER and body is Player\
	and not disabled and is_trigger_exited:
		interact()
