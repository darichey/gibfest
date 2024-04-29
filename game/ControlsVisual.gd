extends Control

@export var arrow_unpressed_texture: Texture2D
@export var arrow_pressed_texture: Texture2D

@export var jump_unpressed_texture: Texture2D
@export var jump_pressed_texture: Texture2D

func update(node, input):
	if Input.is_action_pressed(input):
		node.texture = arrow_pressed_texture
	else:
		node.texture = arrow_unpressed_texture

func _draw() -> void:
	update($ForwardRect/TextureRect, "move_forward")
	update($BackRect/TextureRect, "move_back")
	update($LeftRect/TextureRect, "move_left")
	update($RightRect/TextureRect, "move_right")
	
	if Input.is_action_pressed("move_jump"):
		$JumpRect/TextureRect.texture = jump_pressed_texture
	else:
		$JumpRect/TextureRect.texture = jump_unpressed_texture

func _process(delta: float) -> void:
	self.queue_redraw()
