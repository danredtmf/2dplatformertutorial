class_name RiddleDuplicates
extends Control

enum DuplicateItems { Square, Circle, Triangle, Star, House, Heart, Moon, Flower }

const DUPLICATE_ITEM := preload("res://objects/riddles/duplicates/duplicate_item/duplicate_item.tscn")
const DUPLICATE_OBJECT := preload("res://objects/riddles/duplicates/duplicate/duplicate.tscn")

static var square_sprite := preload("res://resources/sprites/delete_duplicates_game/tabler_square-filled.png")
static var square_sprite_hover := preload("res://resources/sprites/delete_duplicates_game/tabler_square-filled_hover.png")
static var circle_sprite := preload("res://resources/sprites/delete_duplicates_game/gravity-ui_circle-fill.png")
static var circle_sprite_hover := preload("res://resources/sprites/delete_duplicates_game/gravity-ui_circle-fill_hover.png")
static var triangle_sprite := preload("res://resources/sprites/delete_duplicates_game/bi_triangle-fill.png")
static var triangle_sprite_hover := preload("res://resources/sprites/delete_duplicates_game/bi_triangle-fill_hover.png")
static var star_sprite := preload("res://resources/sprites/delete_duplicates_game/tdesign_star-filled.png")
static var star_sprite_hover := preload("res://resources/sprites/delete_duplicates_game/tdesign_star-filled_hover.png")
static var house_sprite := preload("res://resources/sprites/delete_duplicates_game/ph_house-fill.png")
static var house_sprite_hover := preload("res://resources/sprites/delete_duplicates_game/ph_house-fill_hover.png")
static var heart_sprite := preload("res://resources/sprites/delete_duplicates_game/tabler_heart-filled.png")
static var heart_sprite_hover := preload("res://resources/sprites/delete_duplicates_game/tabler_heart-filled_hover.png")
static var moon_sprite := preload("res://resources/sprites/delete_duplicates_game/ph_moon-fill.png")
static var moon_sprite_hover := preload("res://resources/sprites/delete_duplicates_game/ph_moon-fill_hover.png")
static var flower_sprite := preload("res://resources/sprites/delete_duplicates_game/ph_flower-fill.png")
static var flower_sprite_hover := preload("res://resources/sprites/delete_duplicates_game/ph_flower-fill_hover.png")

@onready var game_name: Label = %GameName
@onready var main_v_box: VBoxContainer = %MainVBox
@onready var game_zone: Node2D = %GameZone
@onready var objects: Node2D = %Objects
@onready var item_list: HFlowContainer = %ItemList
@onready var exit_button: Button = %ExitButton
@onready var viewport: SubViewport = %SubViewport

var min_duplicate_items := 1
var max_duplicate_items := DuplicateItems.size()

@export var duplicate_items := 3
@export var min_duplicate_items_count := 1
@export var max_duplicate_items_count := 5
@export var mouse_point_size := 20.0

var riddle_object: RiddleObject
var items := []
var duplicate_entered: Node2D
var magic_vector: Vector2 # выравнивает позицию мыши внутри SubViewport
var game_passed := false

var shape_info = CircleShape2D.new()
var shape_param = PhysicsShapeQueryParameters2D.new()

var random := RandomNumberGenerator.new()

func _ready() -> void:
	random.randomize()
	_config()
	_generate_items()

func delete_duplicates() -> void:
	objects.get_children().any(queue_free)

func _config() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	delete_duplicates()
	
	shape_info.radius = mouse_point_size
	shape_param.shape_rid = shape_info.get_rid()
	
	duplicate_items = int(clamp(duplicate_items, min_duplicate_items, max_duplicate_items))

func _generate_items() -> void:
	items = []
	var counts := []
	
	for i in range(DuplicateItems.size()):
		items.append(i)
		var count = random.randi_range(min_duplicate_items_count, max_duplicate_items_count)
		counts.append(count)
	
	items.shuffle()
	counts.shuffle()
	
	for _i in range(DuplicateItems.size() - duplicate_items):
		items.pop_front()
		counts.pop_front()
	
	for i in range(items.size()):
		var item = DUPLICATE_ITEM.instantiate() as DuplicateItem
		item.id_item = items[i]
		item.count = counts[i]
		item_list.add_child(item)
	
	_generate_duplicate_items()

func _generate_duplicate_items() -> void:
	delete_duplicates()
	for id in items:
		_spawn_duplicate(id)

func _spawn_duplicate(id: int) -> void:
	var min_position_x := 100.0
	var max_position_x := 700.0
	
	var min_position_y := 100.0
	var max_position_y := 400.0
	
	var obj = DUPLICATE_OBJECT.instantiate()
	var random_position := Vector2(
		random.randf_range(min_position_x, max_position_x),
		random.randf_range(min_position_y, max_position_y)
	)
	obj.id_item = id
	obj.global_position = random_position
	objects.add_child(obj)

func _check_duplicate(duplicate_object: Node2D) -> void:
	for item in item_list.get_children():
		if item.id_item == duplicate_object.id_item:
			var id = duplicate_object.id_item
			item.count -= 1
			item.call_deferred("ui_update")
			if item.count < 1:
				item.call_deferred("queue_free")
				duplicate_object.queue_free()
			else:
				duplicate_object.queue_free()
				_spawn_duplicate(id)
			break

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("click") and not game_passed:
		if is_instance_valid(duplicate_entered):
			_check_duplicate(duplicate_entered)
	
	if item_list.get_child_count() < 1:
		game_passed = true
		exit_button.disabled = true
		await get_tree().create_timer(1.0).timeout
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		EventBus.riddle_solved.emit(riddle_object)
		queue_free()
	else:
		game_passed = false

func shape_cast() -> void:
	magic_vector = Vector2(main_v_box.position.x, 105)
	
	var direct_state = viewport.world_2d.direct_space_state
	shape_param.transform.origin = get_global_mouse_position() - magic_vector
	var shape = direct_state.intersect_shape(shape_param)
	
	if shape.size() > 0:
		var info = shape[0] as Dictionary
		if info.has("collider"):
			var obj = info["collider"] as Node2D
			if obj.is_in_group("duplicate"):
				if is_instance_valid(duplicate_entered):
					duplicate_entered.call_deferred("normal")
					duplicate_entered = obj
					duplicate_entered.call_deferred("hover")
				else:
					duplicate_entered = obj
					duplicate_entered.call_deferred("hover")
		else:
			if is_instance_valid(duplicate_entered):
				duplicate_entered.call_deferred("normal")
				duplicate_entered = null
	else:
		if is_instance_valid(duplicate_entered):
			duplicate_entered.call_deferred("normal")
			duplicate_entered = null

func _physics_process(_delta: float) -> void:
	shape_cast()

func _on_exit_button_pressed() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	EventBus.set_busy_player.emit(false)
	queue_free()
