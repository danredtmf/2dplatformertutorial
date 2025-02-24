class_name Player
extends CharacterBody2D

enum State { Idle, Move, Jump }

const SPEED = 300.0
const JUMP_VELOCITY = -600.0

var current_state: State = State.Idle
var is_busy: bool

@onready var _animation: AnimatedSprite2D = $Animation
@onready var _interactive_ui: InteractiveUI = $InteractiveUI

func _ready() -> void:
	add_to_group("Player")
	_set_state(current_state)

func set_busy(value: bool) -> void:
	is_busy = value

func get_interactive_ui() -> InteractiveUI:
	return _interactive_ui

func _set_state(value: State) -> void:
	current_state = value
	_check_state()

func _check_state() -> void:
	match current_state:
		State.Idle:
			_animation.play("default")
		State.Move:
			_animation.play("move")
		State.Jump:
			_animation.play("jump")

func _physics_process(delta: float) -> void:
	# Гравитация
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	if not is_busy:
		# Прыжок
		if Input.is_action_just_pressed("jump") and is_on_floor():
			velocity.y = JUMP_VELOCITY
		
		# Движение
		var direction := Input.get_axis("left", "right")
		if direction:
			velocity.x = direction * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
	
	# Отражение анимации по горизонтали
	if velocity.x < 0.0:
		_animation.flip_h = true
	else:
		_animation.flip_h = false
	
	# Переключение состояний анимации
	if velocity.x != 0.0 and is_on_floor():
		_set_state(State.Move)
	elif velocity.x != 0.0 and velocity.y != 0.0 and not is_on_floor():
		_set_state(State.Jump)
	else:
		_set_state(State.Idle)
	
	move_and_slide()
