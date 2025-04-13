extends CPUParticles2D

var id_item: int

func _ready() -> void:
	_init_texture()
	emitting = true

func _init_texture() -> void:
	match id_item:
		RiddleDuplicates.DuplicateItems.Square:
			texture = RiddleDuplicates.square_sprite
		RiddleDuplicates.DuplicateItems.Circle:
			texture = RiddleDuplicates.circle_sprite
		RiddleDuplicates.DuplicateItems.Triangle:
			texture = RiddleDuplicates.triangle_sprite
		RiddleDuplicates.DuplicateItems.Star:
			texture = RiddleDuplicates.star_sprite
		RiddleDuplicates.DuplicateItems.House:
			texture = RiddleDuplicates.house_sprite
		RiddleDuplicates.DuplicateItems.Heart:
			texture = RiddleDuplicates.heart_sprite
		RiddleDuplicates.DuplicateItems.Moon:
			texture = RiddleDuplicates.moon_sprite
		RiddleDuplicates.DuplicateItems.Flower:
			texture = RiddleDuplicates.flower_sprite

func _process(_delta: float) -> void:
	if not emitting:
		queue_free()
