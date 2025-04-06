class_name BaseLevel
extends Node2D

# Интерфейсы загадок
const RIDDLE_LINES := preload("res://objects/riddles/lines/riddle_lines.tscn")
const RIDDLE_AUTO := preload("res://objects/riddles/auto/riddle_auto.tscn")

@onready var game_over_ui: Control = $FGLayer/GameOverUI
@onready var _riddles = %Riddles

func _ready() -> void:
	EventBus.interactive_item_interacted.connect(_on_interactive_item_interacted.bind())
	EventBus.riddle_solved.connect(_on_riddle_solved.bind())
	EventBus.get_caught.connect(_on_get_caught.bind())
	game_over_ui.hide()

func open_riddle(riddle: RiddleObject) -> void:
	var riddle_ui: Control
	match riddle.riddle_type:
		RiddleObject.RiddleType.LINES:
			print("Открывается загадка \"Соединение Линий\"")
			riddle_ui = RIDDLE_LINES.instantiate() as RiddleLines
			riddle_ui.riddle_object = riddle
		RiddleObject.RiddleType.DUBLICATES:
			print("Открывается загадка \"Удаление Дубликатов\"")
		RiddleObject.RiddleType.AUTO:
			print("Открывается загадка \"Отправка послания\"")
			riddle_ui = RIDDLE_AUTO.instantiate() as RiddleAuto
			riddle_ui.riddle_object = riddle
	
	_riddles.add_child(riddle_ui)

func _on_get_caught() -> void:
	print("Игрока поймали")
	game_over_ui.show()

func _on_interactive_item_interacted(item: InteractiveArea) -> void:
	match item.id:
		"riddle":
			if item is RiddleObject:
				EventBus.set_busy_player.emit(true)
				open_riddle(item)

@warning_ignore("unused_parameter")
func _on_riddle_solved(riddle: RiddleObject) -> void:
	EventBus.set_busy_player.emit(false)
