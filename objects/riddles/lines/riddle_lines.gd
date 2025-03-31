class_name RiddleLines
extends Control

const POINT_RED_COLOR := Color('F60504')
const POINT_BLUE_COLOR := Color('2326F5')
const POINT_YELLOW_COLOR := Color('F9E70C')
const POINT_PURPLE_COLOR := Color('FE04FD')

const CONNECTION_POINT := preload("res://objects/riddles/lines/connection_point/connection_point.tscn")

static var left_point_red_sprite_normal := preload("res://resources/sprites/fix_connections_game/red_point_left_normal.png")
static var left_point_red_sprite_hover := preload("res://resources/sprites/fix_connections_game/red_point_left_hover.png")
static var left_point_blue_sprite_normal := preload("res://resources/sprites/fix_connections_game/blue_point_left_normal.png")
static var left_point_blue_sprite_hover := preload("res://resources/sprites/fix_connections_game/blue_point_left_hover.png")
static var left_point_yellow_sprite_normal := preload("res://resources/sprites/fix_connections_game/yellow_point_left_normal.png")
static var left_point_yellow_sprite_hover := preload("res://resources/sprites/fix_connections_game/yellow_point_left_hover.png")
static var left_point_purple_sprite_normal := preload("res://resources/sprites/fix_connections_game/purple_point_left_normal.png")
static var left_point_purple_sprite_hover := preload("res://resources/sprites/fix_connections_game/purple_point_left_hover.png")
static var right_point_red_sprite_normal := preload("res://resources/sprites/fix_connections_game/red_point_right_normal.png")
static var right_point_red_sprite_hover := preload("res://resources/sprites/fix_connections_game/red_point_right_hover.png")
static var right_point_blue_sprite_normal := preload("res://resources/sprites/fix_connections_game/blue_point_right_normal.png")
static var right_point_blue_sprite_hover := preload("res://resources/sprites/fix_connections_game/blue_point_right_hover.png")
static var right_point_yellow_sprite_normal := preload("res://resources/sprites/fix_connections_game/yellow_point_right_normal.png")
static var right_point_yellow_sprite_hover := preload("res://resources/sprites/fix_connections_game/yellow_point_right_hover.png")
static var right_point_purple_sprite_normal := preload("res://resources/sprites/fix_connections_game/purple_point_right_normal.png")
static var right_point_purple_sprite_hover := preload("res://resources/sprites/fix_connections_game/purple_point_right_hover.png")

enum PointColors { Red, Blue, Yellow, Purple }
enum PointPositions { Left, Right }

@export var mouse_point_size := 10.0
@export var riddle_object: RiddleObject

var positions_and_colors := [
	PointColors.Red,
	PointColors.Blue,
	PointColors.Yellow,
	PointColors.Purple
]

var left_point_positions := [
	Vector2(13, 60),
	Vector2(13, 180),
	Vector2(13, 320),
	Vector2(13, 440),
]

var right_point_positions := [
	Vector2(488, 60),
	Vector2(488, 180),
	Vector2(488, 320),
	Vector2(488, 440),
]

var red_line: Line2D
var blue_line: Line2D
var yellow_line: Line2D
var purple_line: Line2D

var point_entered: Node2D
var point_selected: Node2D
var over := []
var line_active: Line2D
var mouse_pressed := false
var magic_vector: Vector2 # выравнивает позицию мыши внутри SubViewport
var game_passed := false

var shape_info := CircleShape2D.new()
var shape_param := PhysicsShapeQueryParameters2D.new()

@onready var main_v_box: VBoxContainer = %MainVBox
@onready var sub_viewport: SubViewport = %SubViewport
@onready var game_zone: Node2D = %GameZone
@onready var preview: Node2D = %Preview
@onready var lines: Node2D = %Lines
@onready var points: Node2D = %Points
@onready var exit_button: Button = %ExitButton

func _ready() -> void:
	randomize()
	preview.queue_free()
	shape_info.radius = mouse_point_size
	shape_param.shape_rid = shape_info.get_rid()
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	_generate_points()

func _generate_points() -> void:
	var left_positions := positions_and_colors.duplicate()
	var right_positions := positions_and_colors.duplicate()
	
	left_positions.shuffle()
	right_positions.shuffle()
	
	var array_points := []
	var left_array := _generate_array_point(
		PointPositions.Left, left_positions, left_point_positions)
	var right_array := _generate_array_point(
		PointPositions.Right, right_positions, right_point_positions)
	array_points.append_array(left_array)
	array_points.append_array(right_array)
	
	for point in array_points:
		points.add_child(point)

func _generate_array_point(
	point_position: int, positions: Array, points_positions: Array) -> Array:
	var array_points := []
	
	for p_position in positions:
		var point = CONNECTION_POINT.instantiate()
		point.id_color = p_position
		point.id_position = point_position
		var array_position = positions.find(p_position)
		match array_position:
			0:
				point.position = points_positions[array_position]
			1:
				point.position = points_positions[array_position]
			2:
				point.position = points_positions[array_position]
			3:
				point.position = points_positions[array_position]
		array_points.append(point)
	
	return array_points

func _set_line_color(point):
	match point.id_color:
		PointColors.Red:
			line_active.default_color = POINT_RED_COLOR
		PointColors.Blue:
			line_active.default_color = POINT_BLUE_COLOR
		PointColors.Yellow:
			line_active.default_color = POINT_YELLOW_COLOR
		PointColors.Purple:
			line_active.default_color = POINT_PURPLE_COLOR

func _accept_line(point) -> void:
	line_active.set_point_position(over.size() - 1, point.position)
	
	match point.id_color:
		PointColors.Red:
			red_line = line_active.duplicate()
			lines.add_child(red_line)
		PointColors.Blue:
			blue_line = line_active.duplicate()
			lines.add_child(blue_line)
		PointColors.Yellow:
			yellow_line = line_active.duplicate()
			lines.add_child(yellow_line)
		PointColors.Purple:
			purple_line = line_active.duplicate()
			lines.add_child(purple_line)
	point_selected = null
	over = []
	line_active.queue_free()

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("click") and not game_passed:
		if point_entered != null and point_selected == null:
			point_selected = point_entered
			over.append(point_entered.position)
			over.append(point_entered.position)
			line_active = Line2D.new()
			_set_line_color(point_selected)
			lines.add_child(line_active)
			line_active.points = over
	
	if Input.is_action_pressed("click") and not game_passed:
		if point_selected:
			line_active.points = over
			line_active.set_point_position(
				over.size() - 1, get_global_mouse_position() - magic_vector
			)
	
	if Input.is_action_just_released("click") and not game_passed:
		if point_entered and point_selected and \
		point_selected != point_entered and \
		point_entered.id_color == point_selected.id_color:
			_accept_line(point_entered)
		else:
			point_selected = null
			over = []
			if is_instance_valid(line_active):
				line_active.queue_free()
	
	if is_instance_valid(red_line) and \
	is_instance_valid(blue_line) and \
	is_instance_valid(yellow_line) and \
	is_instance_valid(purple_line) and not game_passed:
		await get_tree().create_timer(1.0).timeout
		game_passed = true
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		EventBus.riddle_solved.emit(riddle_object)
		queue_free()
	else:
		game_passed = false

func shape_cast() -> void:
	magic_vector = Vector2(main_v_box.position.x, 105)
	
	var direct_state = sub_viewport.world_2d.direct_space_state
	shape_param.transform.origin = get_global_mouse_position() - magic_vector
	var shape = direct_state.intersect_shape(shape_param)
	
	if shape.size() > 0:
		var info = shape[0] as Dictionary
		if info.has("collider"):
			var obj = info["collider"] as Node2D
			if obj.is_in_group("Point"):
				if is_instance_valid(point_entered):
					point_entered.call_deferred("normal")
					point_entered = obj
					point_entered.call_deferred("hover")
				else:
					point_entered = obj
					point_entered.call_deferred("hover")
		else:
			if is_instance_valid(point_entered):
				point_entered.call_deferred("normal")
				point_entered = null
	else:
		if is_instance_valid(point_entered):
			point_entered.call_deferred("normal")
			point_entered = null

func _physics_process(_delta: float) -> void:
	shape_cast()

# Присоедините сигнал `pressed` от `ExitButton`
func _on_exit_button_pressed() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	EventBus.set_busy_player.emit(false)
	queue_free()
