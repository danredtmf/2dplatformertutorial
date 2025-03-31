class_name ConnectionPoint
extends StaticBody2D

@onready var sprite: Sprite2D = %Sprite

var id_color: int
var id_position: int

var normal_texture: Texture
var hover_texture: Texture

func _ready() -> void:
	_init_image()

func _init_image() -> void:
	match id_position:
		RiddleLines.PointPositions.Left:
			match id_color:
				RiddleLines.PointColors.Red:
					normal_texture = RiddleLines.left_point_red_sprite_normal
					hover_texture = RiddleLines.left_point_red_sprite_hover
				RiddleLines.PointColors.Blue:
					normal_texture = RiddleLines.left_point_blue_sprite_normal
					hover_texture = RiddleLines.left_point_blue_sprite_hover
				RiddleLines.PointColors.Yellow:
					normal_texture = RiddleLines.left_point_yellow_sprite_normal
					hover_texture = RiddleLines.left_point_yellow_sprite_hover
				RiddleLines.PointColors.Purple:
					normal_texture = RiddleLines.left_point_purple_sprite_normal
					hover_texture = RiddleLines.left_point_purple_sprite_hover
		RiddleLines.PointPositions.Right:
			match id_color:
				RiddleLines.PointColors.Red:
					normal_texture = RiddleLines.right_point_red_sprite_normal
					hover_texture = RiddleLines.right_point_red_sprite_hover
				RiddleLines.PointColors.Blue:
					normal_texture = RiddleLines.right_point_blue_sprite_normal
					hover_texture = RiddleLines.right_point_blue_sprite_hover
				RiddleLines.PointColors.Yellow:
					normal_texture = RiddleLines.right_point_yellow_sprite_normal
					hover_texture = RiddleLines.right_point_yellow_sprite_hover
				RiddleLines.PointColors.Purple:
					normal_texture = RiddleLines.right_point_purple_sprite_normal
					hover_texture = RiddleLines.right_point_purple_sprite_hover
	sprite.texture = normal_texture

func hover() -> void:
	sprite.texture = hover_texture

func normal() -> void:
	sprite.texture = normal_texture
