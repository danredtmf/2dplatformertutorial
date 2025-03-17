class_name EnemyBase
extends CharacterBody2D

enum States { IDLE, CHASE, DIE }

var state: States = States.IDLE:
	set(value):
		state = value
		_check_state()
	get:
		return state

@export var health: int
@export var speed: float
@export var has_gravity: bool

var _chase_run: bool
var _player: Player

@onready var _animation: AnimatedSprite2D = $Animation
@onready var _animation_player: AnimationPlayer = $AnimationPlayer
@onready var _chase_zone: Area2D = $ChaseZone

func _ready() -> void:
	state = States.IDLE

func _draw():
	var shape_nodes := _chase_zone.get_children()
	
	if shape_nodes.size() > 0:
		for collision: CollisionShape2D in shape_nodes:
			var rect = collision.shape.get_rect()
			var color := Color.ORANGE_RED
			
			color.a = 0.15
			
			draw_rect(rect, color, false, 5.0)

func _physics_process(delta: float) -> void:
	if not is_instance_valid(_player):
		_player = get_tree().get_first_node_in_group("Player") as Player
	
	if has_gravity and not is_on_floor():
		velocity += get_gravity() * delta
	
	if _chase_run:
		var player_direction := \
		global_position.direction_to(_player.global_position)
		
		velocity += player_direction.normalized() * speed * delta
	
	# Отражение анимации по горизонтали
	if velocity.x < 0.0:
		_animation.flip_h = true
	else:
		_animation.flip_h = false
	
	move_and_slide()

func hit() -> void:
	health -= 1
	
	if health < 1:
		state = States.DIE

func _check_state() -> void:
	match state:
		States.IDLE:
			_chase_run = false
		States.CHASE:
			_chase_run = true
		States.DIE:
			_die()

func _play_death_animation() -> void:
	if not _animation_player.is_playing():
		_animation_player.play("death")

# Пригодится позже, нужно написать
func _die() -> void:
	pass

# Присоединить сигнал `body_entered`
# От объекта `ChaseZone`
# К родительскому объекту (`EnemyBase`)
func _on_chase_zone_body_entered(body: Node2D) -> void:
	if body is Player:
		state = States.CHASE

func _on_catch_zone_body_entered(body: Node2D) -> void:
	if body is Player:
		body.get_caught()
