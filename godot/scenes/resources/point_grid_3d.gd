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
extends ArrayMesh
class_name PointGrid3D

@export var dimensions:Vector3i = Vector3i(10, 10, 10):
	get:
		return dimensions
	set(value):
		if value == dimensions:
			return
		dimensions = value
		
		gen_mesh()
		
		
@export var material:Material:
	get:
		return material
	set(value):
		if value == material:
			return
		material = value
		
		gen_mesh()

func gen_mesh():
	clear_surfaces()
	
	var vertices = PackedVector3Array()
	
	for k in dimensions.z:
		for j in dimensions.y:
			for i in dimensions.x:
				vertices.push_back(Vector3(i, j, k) / Vector3(dimensions + Vector3i.ONE))

	# Initialize the ArrayMesh.
	var arr_mesh = ArrayMesh.new()
	var arrays = []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = vertices

	# Create the Mesh.
	add_surface_from_arrays(Mesh.PRIMITIVE_POINTS, arrays)
	surface_set_material(0, material)
