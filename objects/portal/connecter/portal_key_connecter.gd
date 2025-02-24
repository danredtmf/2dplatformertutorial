class_name PortalKeyConnecter
extends Node2D

@export var portal: Portal
@export var portal_key: PortalKey

var _portal_key_interactive_area: InteractiveArea

func _ready() -> void:
	EventBus.interactive_item_interacted.connect(
		_on_interactive_item_interacted.bind()
	)
	if portal_key:
		_portal_key_interactive_area = portal_key.get_interactive()
	else:
		printerr(
			"[%s, %s]: нет привязки к объекту класса `PortalKey`" %\
			[name, owner.scene_file_path]
		)

func _logic() -> void:
	if portal:
		portal.set_state(Portal.State.OPEN)
	else:
		printerr(
			"[%s, %s]: нет привязки к объекту класса `Portal`" %\
			[name, owner.scene_file_path]
		)

func _on_interactive_item_interacted(item: InteractiveArea) -> void:
	match item.id:
		"portal_key":
			if item == _portal_key_interactive_area:
				_logic()
