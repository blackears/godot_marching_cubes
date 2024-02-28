# MIT License
#
# Copyright (c) 2023 Mark McKay
# https://github.com/blackears/godot_marching_cubes
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

@tool
extends Control
class_name ImageStackViewer

@export var image_list:Array[Image]:
	get:
		return image_list
	set(value):
		image_list = value
		update_ui()

func update_ui():
	%spin_cur_image.max_value = image_list.size() - 1
	%spin_cur_image.value = min(%spin_cur_image.value, image_list.size())
	if image_list.is_empty():
		%img_texture.custom_minimum_size = Vector2.ZERO
	else:
		%img_texture.custom_minimum_size = image_list[0].get_size()
	
	var img_idx:int = %spin_cur_image.value
	var tex = null if image_list.is_empty() else image_list[img_idx]
	%img_texture.texture = ImageTexture.create_from_image(tex)
	
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_spin_cur_image_value_changed(value:float):
	var img_idx:int = %spin_cur_image.value
	var tex = null if image_list.is_empty() else image_list[img_idx]
	%img_texture.texture = ImageTexture.create_from_image(tex)
#	if image_list.is_empty():
#		%img_texture.size = Vector2.ZERO
#	else:
#		%img_texture.size = image_list[0].get_size()
