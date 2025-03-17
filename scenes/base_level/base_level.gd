class_name BaseLevel
extends Node2D

@onready var game_over_ui: Control = $FGLayer/GameOverUI

func _ready() -> void:
	EventBus.get_caught.connect(_on_get_caught.bind())
	game_over_ui.hide()

func _on_get_caught() -> void:
	print("Игрока поймали")
	game_over_ui.show()
