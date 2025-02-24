class_name WorldCamera
extends Camera2D

@export var player: Player
@export var node_2d: Node2D

var pin_to_player: bool = true

func _ready() -> void:
	add_to_group("WorldCamera")
	if is_instance_valid(player):
		global_position = player.global_position

func set_pin_to_player(value: bool) -> void:
	pin_to_player = value

func _physics_process(_delta: float) -> void:
	if pin_to_player and is_instance_valid(player):
		global_position = player.global_position
	elif not pin_to_player and is_instance_valid(node_2d):
		global_position = node_2d.global_position
