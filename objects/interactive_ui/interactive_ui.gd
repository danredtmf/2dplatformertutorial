class_name InteractiveUI
extends PanelContainer

var is_busy: bool

var _item: InteractiveArea

@onready var _item_name: Label = %ItemName
@onready var _item_desc: Label = %ItemDesc

func _ready() -> void:
	hide()
	_config_signals()

func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("interact") and not is_busy:
		if visible and is_instance_valid(_item):
			_item.interact()

func set_busy(value: bool) -> void:
	is_busy = value

func _config_signals() -> void:
	EventBus.interactive_ui_shown.connect(_on_interactive_ui_shown.bind())
	EventBus.interactive_ui_hide.connect(_on_interactive_ui_hide.bind())

func _on_interactive_ui_shown(new: InteractiveArea) -> void:
	if new == null:
		show()
	elif not _item == new:
		_item = new
		_item_name.text = _item.ui_name
		_item_desc.text = _item.ui_desc
	
	show()

func _on_interactive_ui_hide() -> void:
	hide()
