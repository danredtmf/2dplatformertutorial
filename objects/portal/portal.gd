class_name Portal
extends Node2D

enum Type { COMMON, END }
enum State { CLOSE, OPEN }

@export var state_init: State
@export var type: Type = Type.COMMON
@export var next_portal: Portal
@export var next_level: PackedScene

var state: State = State.CLOSE

@onready var _interactive_area: InteractiveArea = $InteractiveArea
@onready var _animation: AnimatedSprite2D = $Animation

func _ready() -> void:
	state = state_init
	_set_state(state)
	EventBus.interactive_item_interacted.connect(_on_interactive_item_interacted.bind())

func _set_state(value: State) -> void:
	state = value
	_check_state()

func _check_state() -> void:
	match state:
		State.CLOSE:
			_animation.play("default")
			_interactive_area.disabled = true
		State.OPEN:
			_animation.play("open")
			_interactive_area.disabled = false

func _logic() -> void:
	match type:
		Type.COMMON: # Телепортация к другому порталу
			if next_portal != null:
				var player: Player = get_tree().get_first_node_in_group("Player")
				player.global_position = next_portal.global_position
		Type.END: # Переход на другой уровень
			if next_level != null:
				get_tree().change_scene_to_packed(next_level)
			else:
				# Изменим строку, когда появится главное меню
				get_tree().quit()

func _on_interactive_item_interacted(item: InteractiveArea) -> void:
	match item.id:
		"portal":
			if item == _interactive_area:
				_logic()
