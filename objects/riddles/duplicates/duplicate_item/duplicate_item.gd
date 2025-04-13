class_name DuplicateItem
extends Control

@onready var duplicate_rect: TextureRect = $"%DuplicateRect"
@onready var count_info: Label = $"%CountInfo"

var id_item: int
var count: int

func _ready() -> void:
	_init_texture()
	ui_update()

func _init_texture() -> void:
	match id_item:
		RiddleDuplicates.DuplicateItems.Square:
			duplicate_rect.texture = RiddleDuplicates.square_sprite
		RiddleDuplicates.DuplicateItems.Circle:
			duplicate_rect.texture = RiddleDuplicates.circle_sprite
		RiddleDuplicates.DuplicateItems.Triangle:
			duplicate_rect.texture = RiddleDuplicates.triangle_sprite
		RiddleDuplicates.DuplicateItems.Star:
			duplicate_rect.texture = RiddleDuplicates.star_sprite
		RiddleDuplicates.DuplicateItems.House:
			duplicate_rect.texture = RiddleDuplicates.house_sprite
		RiddleDuplicates.DuplicateItems.Heart:
			duplicate_rect.texture = RiddleDuplicates.heart_sprite
		RiddleDuplicates.DuplicateItems.Moon:
			duplicate_rect.texture = RiddleDuplicates.moon_sprite
		RiddleDuplicates.DuplicateItems.Flower:
			duplicate_rect.texture = RiddleDuplicates.flower_sprite

func ui_update() -> void:
	count_info.text = str(count)
