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

extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready():
	%slider_threshold.value = %MarchingCubesViewerGlsl.threshold
	%slider_resolution.value = %MarchingCubesViewerGlsl.cube_resolution
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass



func _on_slider_threshold_value_changed(value):
	%MarchingCubesViewerGlsl.threshold = value


func _on_slider_resolution_value_changed(value):
	%MarchingCubesViewerGlsl.cube_resolution = value


func _on_bn_save_pressed():
	%save_dialog.popup_centered()


func _on_save_dialog_file_selected(save_path:String):
	var path:String = save_path
	if !save_path.to_lower().ends_with(".gltf") && !save_path.to_lower().ends_with(".glb"):
		path = save_path + ".glb"
		
		
	var doc:GLTFDocument = GLTFDocument.new()
	var state:GLTFState = GLTFState.new()
	#var root:Node = plugin.get_editor_interface().get_edited_scene_root()
	#var root_clean:Node3D = clean_flat(root) if %check_flatten.button_pressed else clean_branch(root)
	
	doc.append_from_scene(%MarchingCubesViewerGlsl, state)
	doc.write_to_filesystem(state, path)
		


func _on_bn_load_pressed():
	%load_dialog.popup_centered()


func _on_load_dialog_file_selected(path):
	%MarchingCubesViewerGlsl.image_file = path
	pass # Replace with function body.
