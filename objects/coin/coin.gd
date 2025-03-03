class_name Coin
extends RigidBody2D

var _last_object: EnemyBase
var _can_hit: bool

@onready var _animation_player: AnimationPlayer = $AnimationPlayer
@onready var _interactive_area: InteractiveArea = $InteractiveArea
@onready var _shape_cast_2d: ShapeCast2D = $ShapeCast2D

func _ready() -> void:
	_animation_player.play("show")
	gravity_scale = 0.0

func _physics_process(_delta: float) -> void:
	if _animation_player.is_playing() or not sleeping:
		_can_hit = true
	else:
		_can_hit = false
	
	if _shape_cast_2d.is_colliding() and _can_hit:
		var object := _shape_cast_2d.get_collider(0)
		if object is EnemyBase:
			if object != _last_object:
				_last_object = object
				
				_last_object.hit()
				can_sleep = false
				await _last_object.tree_exited
				can_sleep = true

func get_interactive() -> InteractiveArea:
	return _interactive_area

# Присоединить сигнал `tree_exited`
# От объекта `InteractiveArea`
# К родительскому объекту (`Coin`)
func _on_interactive_area_tree_exited() -> void:
	queue_free()

# Присоединить сигнал `animation_finished`
# От объекта `AnimationPlayer`
# К родительскому объекту (`Coin`)
func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "show":
		gravity_scale = 1.0
