extends CharacterBody2D

const DUPLICATE_ITEM_PARTICLES := preload("res://objects/riddles/duplicates/duplicate_item/particles/duplicate_item_particles.tscn")

@onready var sprite: Sprite2D = %Sprite
@onready var circle_collision: CollisionShape2D = %CircleCollision
@onready var square_collision: CollisionShape2D = $%SquareCollision
@onready var triangle_collision: CollisionPolygon2D = %TriangleCollision
@onready var flower_collision: CollisionPolygon2D = %FlowerCollision
@onready var house_collision: CollisionPolygon2D = %HouseCollision
@onready var moon_collision: CollisionPolygon2D = %MoonCollision
@onready var heart_collision: CollisionPolygon2D = %HeartCollision
@onready var star_collision: CollisionPolygon2D = %StarCollision

@export var min_velocity_speed := 100.0
@export var max_velocity_speed := 200.0

var id_item: int

var normal_texture: Texture
var hover_texture: Texture

var random := RandomNumberGenerator.new()
var particles = DUPLICATE_ITEM_PARTICLES.instantiate()

func _ready() -> void:
	random.randomize()
	velocity = Vector2()
	_randomize_velocity()
	_randomize_velocity_direction()
	_init_texture()
	particles.id_item = id_item

func _randomize_velocity() -> void:
	velocity = Vector2(
		random.randf_range(min_velocity_speed, max_velocity_speed),
		random.randf_range(min_velocity_speed, max_velocity_speed)
	)

func _randomize_velocity_direction() -> void:
	match random.randi_range(0, 2):
		0:
			velocity.x *= -1
			velocity.y *= -1
		1:
			velocity.x *= -1
		2:
			velocity.y *= -1

func _init_texture() -> void:
	match id_item:
		RiddleDuplicates.DuplicateItems.Square:
			add_to_group("square")
			normal_texture = RiddleDuplicates.square_sprite
			hover_texture = RiddleDuplicates.square_sprite_hover
			square_collision.show()
			square_collision.disabled = false
		RiddleDuplicates.DuplicateItems.Circle:
			add_to_group("circle")
			normal_texture = RiddleDuplicates.circle_sprite
			hover_texture = RiddleDuplicates.circle_sprite_hover
			circle_collision.show()
			circle_collision.disabled = false
		RiddleDuplicates.DuplicateItems.Triangle:
			add_to_group("triangle")
			normal_texture = RiddleDuplicates.triangle_sprite
			hover_texture = RiddleDuplicates.triangle_sprite_hover
			triangle_collision.show()
			triangle_collision.disabled = false
		RiddleDuplicates.DuplicateItems.Star:
			add_to_group("star")
			normal_texture = RiddleDuplicates.star_sprite
			hover_texture = RiddleDuplicates.star_sprite_hover
			star_collision.show()
			star_collision.disabled = false
		RiddleDuplicates.DuplicateItems.House:
			add_to_group("house")
			normal_texture = RiddleDuplicates.house_sprite
			hover_texture = RiddleDuplicates.house_sprite_hover
			house_collision.show()
			house_collision.disabled = false
		RiddleDuplicates.DuplicateItems.Heart:
			add_to_group("heart")
			normal_texture = RiddleDuplicates.heart_sprite
			hover_texture = RiddleDuplicates.heart_sprite_hover
			heart_collision.show()
			heart_collision.disabled = false
		RiddleDuplicates.DuplicateItems.Moon:
			add_to_group("moon")
			normal_texture = RiddleDuplicates.moon_sprite
			hover_texture = RiddleDuplicates.moon_sprite_hover
			moon_collision.show()
			moon_collision.disabled = false
		RiddleDuplicates.DuplicateItems.Flower:
			add_to_group("flower")
			normal_texture = RiddleDuplicates.flower_sprite
			hover_texture = RiddleDuplicates.flower_sprite_hover
			flower_collision.show()
			flower_collision.disabled = false
	sprite.texture = normal_texture

func _physics_process(delta: float) -> void:
	var collision_info = move_and_collide(velocity * delta)
	if collision_info:
		velocity = velocity.bounce(collision_info.get_normal())

func hover() -> void:
	sprite.texture = hover_texture

func normal() -> void:
	sprite.texture = normal_texture

func _exit_tree() -> void:
	particles.global_position = global_position
	get_parent().call_deferred("add_child", particles)
