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

signal updated

@export var mesh:ArrayMesh:
	get:
		return mesh
	set(value):
		if (value == mesh):
			return
		mesh = value
		dirty = true

var dirty:bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if dirty:
		%mesh.mesh = mesh
		updated.emit()
		
		dirty = false
	pass
	
func export_gltf():
	#Export
	var doc:GLTFDocument = GLTFDocument.new()
	var state:GLTFState = GLTFState.new()

	doc.append_from_scene($SubViewportContainer/SubViewport/Node3D, state)
	doc.write_to_filesystem(state, "../export/mesh.glb")
	
