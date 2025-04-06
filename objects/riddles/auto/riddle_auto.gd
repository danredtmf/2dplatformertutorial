class_name RiddleAuto
extends Control

@onready var game_name: Label = $"%GameName"

@onready var test_data: PanelContainer = $"%TestData"
@onready var test_data_info: Label = $"%TestDataInfo"
@onready var test_data_progress: ProgressBar = $"%TestDataProgress"

@onready var loading_data: PanelContainer = $"%LoadingData"
@onready var loading_data_info: Label = $"%LoadingDataInfo"
@onready var loading_data_progress: ProgressBar = $"%LoadingDataProgress"

@onready var server_load: PanelContainer = $"%ServerLoad"
@onready var server_load_info: Label = $"%ServerLoadInfo"
@onready var server_load_level: ProgressBar = $"%ServerLoadLevel"
@onready var server_load_level_value: float:
	set(value): _set_server_load_level_value(value)

@onready var server_load_progress: ProgressBar = $"%ServerLoadProgress"

@onready var exit_button: Button = $"%ExitButton"

const progress_bar_style_fg_green := preload("res://resources/styles/progress_bar/fg_green.tres")
const progress_bar_style_fg_yellow := preload("res://resources/styles/progress_bar/fg_yellow.tres")
const progress_bar_style_fg_red := preload("res://resources/styles/progress_bar/fg_red.tres")

var is_busy := false
var riddle_object: RiddleObject

var init_test_data_position: Vector2
var init_loading_data_position: Vector2
var init_server_load_position: Vector2

@export var min_data_duration := 1.0
@export var max_data_duration := 4.0

@export var count_server_load_progress := 15
@export var min_server_load_duration := 0.25
@export var max_server_load_duration := 0.5

var random := RandomNumberGenerator.new()

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	random.randomize()
	
	init_test_data_position = test_data.position
	init_loading_data_position = loading_data.position
	init_server_load_position = server_load.position
	
	_init_config()
	await get_tree().create_timer(1).timeout
	_start_test_data()

func _set_server_load_level_value(value: float) -> void:
	server_load_level.value = value
	
	var previous_style_path = server_load_level.get("theme_override_styles/fill").resource_path
	
	if value >= 0 and value < 50:
		if previous_style_path != progress_bar_style_fg_green.resource_path:
			server_load_level.set("theme_override_styles/fill", progress_bar_style_fg_green)
	elif value >= 50 and value < 70:
		if previous_style_path != progress_bar_style_fg_yellow.resource_path:
			server_load_level.set("theme_override_styles/fill", progress_bar_style_fg_yellow)
	else:
		if previous_style_path != progress_bar_style_fg_red.resource_path:
			server_load_level.set("theme_override_styles/fill", progress_bar_style_fg_red)

func _get_server_load_level_value() -> float:
	return server_load_level.value

func _init_config():
	#exit_button.disabled = true
	
	test_data.position = init_test_data_position
	test_data.modulate = Color.GRAY
	test_data.modulate.a = 0.0
	
	test_data_progress.value = 0
	
	loading_data.position = init_loading_data_position
	loading_data.modulate = Color.GRAY
	loading_data.modulate.a = 0.0
	
	loading_data_progress.value = 0
	
	server_load.position = init_server_load_position
	server_load.modulate = Color.GRAY
	server_load.modulate.a = 0.0
	
	server_load_level.value = 0
	server_load_level.add_theme_stylebox_override("theme_override_styles/fill", progress_bar_style_fg_green)
	
	server_load_progress.value = 0

func _show_window(window: Control) -> void:
	await get_tree().process_frame
	var animation_window = create_tween()
	var previous_position = window.position
	var offset_position = Vector2(0, 100)
	
	animation_window.parallel().tween_property(window, "position", previous_position, 0.5).from(previous_position - offset_position).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	animation_window.parallel().tween_property(window, 'modulate', Color.WHITE, 0.5).from(Color.GRAY).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	animation_window.parallel().tween_property(window, 'modulate:a', 1.0, 0.5).from(0.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	animation_window.play()
	await animation_window.finished
	animation_window.stop()

func _data_animation(window_progress: Control) -> void:
	await get_tree().process_frame
	var duration_array := []
	var progress_array := []
	
	for _i in range(4):
		duration_array.append(random.randf_range(min_data_duration, max_data_duration))
	
	var progress_1 := random.randi_range(1, 25)
	var progress_2 := random.randi_range(1, 25)
	var progress_3 := random.randi_range(1, 25)
	var progress_4 := 100 - (progress_1 + progress_2 + progress_3)
	
	progress_array.append_array([progress_1, progress_2, progress_3, progress_4])
	
	print("Duration Array: ", duration_array)
	print("Progress Array: ", progress_array)
	
	for i in range(4):
		var animation = create_tween()
		var previous_value = window_progress.value
		var final_value = previous_value + progress_array[i]
		print("Previous Value: ", previous_value)
		print("Final Value: ", final_value)
		print("Current Duration Array: ", duration_array[i])
		print("Current Progress Array: ", progress_array[i])
		animation.tween_property(window_progress, 'value', final_value, duration_array[i]).from_current()
		animation.play()
		await animation.finished
		animation.stop()

func _start_test_data() -> void:
	is_busy = true
	await _show_window(test_data)
	await _data_animation(test_data_progress)
	
	await get_tree().create_timer(0.5).timeout
	_start_loading_data()

func _start_loading_data() -> void:
	await _show_window(loading_data)
	await _data_animation(loading_data_progress)
	
	await get_tree().create_timer(0.5).timeout
	_start_server_load()

func _start_server_load() -> void:
	await _show_window(server_load)
	
	var duration_array := []
	var load_array := []
	
	for _i in range(count_server_load_progress):
		duration_array.append(random.randf_range(min_server_load_duration, max_server_load_duration))
	
	for _i in range(count_server_load_progress):
		load_array.append(random.randi_range(0, 100))
	
	server_load_progress.max_value = count_server_load_progress
	
	print("Duration Array: ", duration_array)
	print("Load Array: ", load_array)
	
	for i in range(load_array.size()):
		var animation = create_tween()
		var previous_value = _get_server_load_level_value()
		print("Final Value: ", load_array[i])
		print("Current Duration Array: ", duration_array[i])
		animation.parallel().tween_method(_set_server_load_level_value, previous_value, float(load_array[i]), duration_array[i])
		animation.parallel().tween_property(server_load_progress, 'value', i, duration_array[i]).from_current()
		animation.play()
		await animation.finished
		animation.stop()
	
	var all_load: int = 0
	var average_load: int
	for i in load_array:
		all_load += i
	average_load = int(float(all_load) / load_array.size())
	print("Average Load: ", average_load)
	
	var animation = create_tween()
	var previous_value = _get_server_load_level_value()
	animation.parallel().tween_property(server_load_level, 'value', 0, 1).from_current()
	animation.parallel().tween_method(_set_server_load_level_value, previous_value, float(0), 1)
	animation.parallel().tween_property(server_load_progress, 'value', server_load_progress.max_value, 1).from_current()
	animation.play()
	await animation.finished
	animation.stop()
	is_busy = false
	_closing()
	
	#next_button.disabled = false

func _hide_window(window: Control) -> void:
	await get_tree().process_frame
	var animation_window = create_tween()
	var previous_position = window.position
	var offset_position = Vector2(0, 100)
	
	animation_window.parallel().tween_property(window, "position", previous_position - offset_position, 0.5).from(previous_position).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	animation_window.parallel().tween_property(window, 'modulate', Color.GRAY, 0.5).from(Color.WHITE).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	animation_window.parallel().tween_property(window, 'modulate:a', 0.0, 0.5).from(1.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	animation_window.play()
	await animation_window.finished
	animation_window.stop()

func _closing() -> void:
	exit_button.disabled = true
	
	await get_tree().create_timer(1.0).timeout
	
	if is_busy:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		EventBus.set_busy_player.emit(false)
		queue_free()
	else:
		await _hide_window(server_load)
		await _hide_window(loading_data)
		await _hide_window(test_data)
		
		EventBus.riddle_solved.emit(riddle_object)
		
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		EventBus.set_busy_player.emit(false)
		queue_free()

func _on_exit_button_pressed() -> void:
	_closing()
