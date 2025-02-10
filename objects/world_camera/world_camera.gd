extends Camera2D

@export var player: Player

var pin_to_player: bool = true

func _ready() -> void:
	if is_instance_valid(player):
		global_position = player.global_position

func set_pin_to_player(value: bool) -> void:
	pin_to_player = value

func _physics_process(_delta: float) -> void:
	if pin_to_player and is_instance_valid(player):
		global_position = player.global_position
