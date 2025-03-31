extends BaseLevel

@onready var portal_3: Portal = $Objects/Portal3

func _on_riddle_solved(riddle: RiddleObject) -> void:
	super._on_riddle_solved(riddle)
	
	match riddle.riddle_id:
		"open_last_portal":
			riddle.queue_free()
			portal_3.set_state(Portal.State.OPEN)
