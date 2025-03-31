class_name PlayerCoinManager
extends Node2D

enum States { OFF, ON }

const COIN_SCENE := preload("res://objects/coin/coin.tscn")
const COIN_SPRITE := preload("res://resources/sprites/coin.png")

const PREVIEW_POSITION_LIMIT := 200.0

var coins: int
var state: States = States.OFF

var _can_drop: bool
var _preview_coin: Sprite2D

func _ready() -> void:
	add_to_group("PlayerCoinManager")
	EventBus.interactive_item_interacted.connect(
		_on_interactive_item_interacted.bind()
	)
	
	if owner is not Player:
		printerr(
			"[%s, %s]: объект вне `Player`" %\
			[name, owner.scene_file_path]
		)

func _set_state(value: States) -> void:
	state = value
	_check_state()

func _check_state() -> void:
	var player := owner as Player
	var interactive_ui := player.get_interactive_ui()
	var world_camera := get_tree().get_first_node_in_group("WorldCamera") as WorldCamera
	match state:
		States.OFF:
			player.set_busy(false)
			interactive_ui.set_busy(false)
			_remove_preview_coin()
			_pin_to_world_camera(world_camera, player)
		States.ON:
			player.set_busy(true)
			interactive_ui.set_busy(true)
			_add_preview_coin()
			_pin_to_world_camera(world_camera, _preview_coin)

func _pin_to_world_camera(camera: WorldCamera, node_2d: Node2D) -> void:
	if node_2d is Player:
		camera.node_2d = null
		camera.pin_to_player = true
	else:
		camera.node_2d = node_2d
		camera.pin_to_player = false

func _add_preview_coin() -> void:
	var sprite := Sprite2D.new()
	sprite.texture = COIN_SPRITE
	sprite.modulate.a = 0.5
	_preview_coin = sprite
	add_child(_preview_coin)
	_check_preview_coin_position()

func _check_preview_coin_position() -> void:
	# Проверка, сможем ли мы бросить в место монетку
	if is_instance_valid(_preview_coin):
		var world := get_world_2d()
		var space_state := world.direct_space_state
		var parameters := PhysicsShapeQueryParameters2D.new()
		var shape := RectangleShape2D.new()
		
		shape.size = Vector2(60, 60)
		
		parameters.collision_mask = 1
		parameters.transform = _preview_coin.global_transform
		parameters.shape = shape
		
		var results := space_state.intersect_shape(parameters)
		
		if results.size() > 0:
			_can_drop = false
			_preview_coin.self_modulate = Color.RED
		else:
			_can_drop = true
			_preview_coin.self_modulate = Color.WHITE

func _move_preview_coin(direction: Vector2) -> void:
	match direction:
		Vector2.UP:
			_preview_coin.position.y = clampf(
				_preview_coin.position.y - 20,
				-PREVIEW_POSITION_LIMIT,
				PREVIEW_POSITION_LIMIT
			)
		Vector2.DOWN:
			_preview_coin.position.y = clampf(
				_preview_coin.position.y + 20,
				-PREVIEW_POSITION_LIMIT,
				PREVIEW_POSITION_LIMIT
			)
		Vector2.LEFT:
			_preview_coin.position.x = clampf(
				_preview_coin.position.x - 20,
				-PREVIEW_POSITION_LIMIT,
				PREVIEW_POSITION_LIMIT
			)
		Vector2.RIGHT:
			_preview_coin.position.x = clampf(
				_preview_coin.position.x + 20,
				-PREVIEW_POSITION_LIMIT,
				PREVIEW_POSITION_LIMIT
			)
	
	_check_preview_coin_position()

func _remove_preview_coin() -> void:
	if is_instance_valid(_preview_coin):
		_preview_coin.queue_free()
		_preview_coin = null

func _drop() -> void:
	if coins > 0 and _can_drop:
		var new_coin := COIN_SCENE.instantiate()
		# На уровне должен быть узел `Objects` типа `Node2D`
		# По иерархии он должен быть выше узла `Player`
		get_tree().current_scene.get_node("Objects").add_child(new_coin)
		new_coin.global_position = _preview_coin.global_position
		coins -= 1
		
		if coins < 1:
			_set_state(States.OFF)

func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("drop") and \
	not (owner as Player).is_caught and \
	not (owner as Player).is_busy:
		match state:
			States.OFF:
				if coins > 0:
					_set_state(States.ON)
			States.ON:
				_set_state(States.OFF)
	elif state == States.ON:
		if Input.is_action_just_pressed("interact"):
			_drop()
		elif Input.is_action_pressed("ui_up"):
			_move_preview_coin(Vector2.UP)
		elif Input.is_action_pressed("ui_down"):
			_move_preview_coin(Vector2.DOWN)
		elif Input.is_action_pressed("ui_left"):
			_move_preview_coin(Vector2.LEFT)
		elif Input.is_action_pressed("ui_right"):
			_move_preview_coin(Vector2.RIGHT)

func _on_interactive_item_interacted(item: InteractiveArea) -> void:
	match item.id:
		"coin":
			coins += 1
