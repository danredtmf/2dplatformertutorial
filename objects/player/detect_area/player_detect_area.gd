@tool
class_name PlayerDetectArea
extends Area2D

@export var size := Vector2(20, 20)

var _last_area: InteractiveArea

@onready var _shape: CollisionShape2D = $Shape

func _ready() -> void:
	_shape.shape = _shape.shape.duplicate()
	_change_size()

func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		_change_size()

func _change_size() -> void:
	_shape.shape.size = size

func _on_area_entered(area: Area2D) -> void:
	if area is InteractiveArea:
		if not area.disabled and area.type != InteractiveArea.Type.TRIGGER:
			if _last_area == null or area != _last_area:
				_last_area = area
				EventBus.interactive_ui_shown.emit(area)
			elif area == _last_area:
				EventBus.interactive_ui_shown.emit(null)
		else:
			EventBus.interactive_ui_hide.emit()
	else:
		EventBus.interactive_ui_hide.emit()

func _on_area_exited(area: Area2D) -> void:
	if area is InteractiveArea:
		if _last_area == area:
			EventBus.interactive_ui_hide.emit()
