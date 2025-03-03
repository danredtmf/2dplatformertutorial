class_name FloatingEnemy
extends EnemyBase

func _ready() -> void:
	super._ready()
	_animation.play("default")

func _die() -> void:
	_play_death_animation()
	await _animation_player.animation_finished
	
	queue_free()
