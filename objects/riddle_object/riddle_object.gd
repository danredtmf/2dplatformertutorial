@tool
class_name RiddleObject
extends InteractiveArea

enum RiddleType { LINES, DUBLICATES, AUTO }

@export var riddle_type: RiddleType
@export var riddle_id: String

func _ready():
	super._ready()

func _process(delta):
	super._process(delta)
