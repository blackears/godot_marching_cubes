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
extends Node3D
class_name MarchingCubesViewerGlsl

@export_file("*.zip") var image_file:String:
	get:
		return image_file
	set(value):
		if value == image_file:
			return
		image_file = value
		flag_reload_image_file = true
		flag_update_mesh = true
		
@export_range(0, 1) var threshold:float = .5:
	get:
		return threshold
	set(value):
		if value == threshold:
			return
		threshold = value
		flag_update_mesh = true


@export_range(0, 1) var cube_resolution:float = .7:
	get:
		return cube_resolution
	set(value):
		if value == cube_resolution:
			return
		cube_resolution = value
		flag_update_mesh = true
		
var flag_reload_image_file:bool = false
var flag_update_mesh:bool = false
		
var density_tex_rid:RID
var grad_tex_rid:RID
var mesh_size_base:Vector3i

var rd:RenderingDevice

var display_mesh:MeshInstance3D

var mesh_build_tool:MeshBuilderTool

func reload_image():
	if !FileAccess.file_exists(image_file):
		return
	
	var ar:ZippedImageArchive_RF_3D = ZippedImageArchive_RF_3D.new()
	ar.zip_file = image_file
	
	#var rd:RenderingDevice = RenderingServer.create_local_rendering_device()
	var grad_gen:SobelGradientGenerator = SobelGradientGenerator.new(rd)
	var img_size:Vector3i = ar.get_size()
	var image_list:Array[Image] = ar.get_image_list().duplicate()
#	var grad_image_list:Array[Image] = grad_gen.calculate_gradient_from_image_stack(image_list)

	mesh_size_base = Vector3i(image_list[0].get_width(), \
		image_list[0].get_height(), image_list.size())

	#print("mesh_size_base ", mesh_size_base)

	var glsl_util:GLSLUtil = GLSLUtil.new(rd)
	var image_list_with_mipmaps:Array[Image] = glsl_util.create_mipmaps_from_image_stack(image_list, RenderingDevice.DATA_FORMAT_R32_SFLOAT)
	#density_tex_rid = glsl_util.create_texture_image_from_image_stack(image_list, RenderingDevice.DATA_FORMAT_R32_SFLOAT, true)
	#grad_tex_rid = glsl_util.create_texture_image_from_image_stack(grad_image_list, RenderingDevice.DATA_FORMAT_R32G32B32A32_SFLOAT, true)
	#grad_tex_rid = grad_gen.calculate_gradient_image_from_image(density_tex_rid, mesh_size_base, true)
	
	#var count:int = 0
	#for img in image_list_with_mipmaps:
		#img.save_png("../export/images/density_%d.png" % count)
		#count += 1
		
	var ss = image_list_with_mipmaps.size()
		
	var gradient_list_with_mipmaps:Array[Image]
	var mipmap_sizes:Array[Vector3i] = GLSLUtil.calc_mipmap_sizes(mesh_size_base)
	var slice_start:int = 0
	for size in mipmap_sizes:
		#print("slice_start ", slice_start)
		var mipmap_stack:Array[Image] = image_list_with_mipmaps.slice(slice_start, slice_start + size.z)
		var grad_img:Array[Image] = grad_gen.calculate_gradient_from_image_stack(mipmap_stack)
		gradient_list_with_mipmaps.append_array(grad_img)
		slice_start += size.z

	#count = 0
	#for img in gradient_list_with_mipmaps:
		#img.save_png("../export/images/grad_%d.png" % count)
		#count += 1
	
	density_tex_rid = glsl_util.create_texture_image_from_image_stack_with_mipmaps(image_list_with_mipmaps, RenderingDevice.DATA_FORMAT_R32_SFLOAT, mesh_size_base, mipmap_sizes.size())
	grad_tex_rid = glsl_util.create_texture_image_from_image_stack_with_mipmaps(gradient_list_with_mipmaps, RenderingDevice.DATA_FORMAT_R32G32B32A32_SFLOAT, mesh_size_base, mipmap_sizes.size())
	
		
	var min_dim:float = min(mesh_size_base.x, mesh_size_base.y, mesh_size_base.z)

	var xform:Transform3D = Transform3D(Basis.from_scale(Vector3(mesh_size_base / min_dim)))
	xform = xform.translated_local(Vector3(-.5, -.5, -.5))
	display_mesh.transform = xform

#class BuildMestTool extends RefCounted:
	#signal done
	#var thread:Thread = Thread.new()
	#var work:Callable
	#
	#func start(callable:Callable):
		#thread.start(do_work)
	#
	#func do_work():
		#work.call()
		#done.emit()

func build_mesh():
	if cube_resolution <= 0:
		return
	if threshold <= 0 || threshold >= 1:
		return
	
	var cube_gen:MarchingCubesGeneratorGLSLVariable = MarchingCubesGeneratorGLSLVariable.new(rd)

	#var start_time_msec = Time.get_ticks_msec()
	#var mesh_size_base:Vector3i = Vector3i(image_list[0].get_width(), \
		#image_list[0].get_height(), image_list.size())
	var mipmap_sizes:Array[Vector3i] = GLSLUtil.calc_mipmap_sizes(mesh_size_base)
	var mipmap_level:float = mipmap_sizes.size() * (1 - cube_resolution)
	var mesh_size:Vector3i = mipmap_sizes[int(mipmap_level)]
	

	var mesh:ArrayMesh = cube_gen.generate_mesh(mesh_size, threshold, int(mipmap_level), \
		density_tex_rid, grad_tex_rid)
	#var end_time_msec = Time.get_ticks_msec()

	display_mesh.mesh = mesh
	#print("time delta msec ", (end_time_msec - start_time_msec))
	#var dens_tex_rid:RID = cube_gen.create_texture_image_from_image_stack(image_list, true)
	
	#mutex.lock()
	#if mesh_build_state != BuildState.BUILDING:
		#push_error("Should be in BUILDING state")
	#print("set mesh_build_state = BuildState.DONE")
	#mesh_build_state = BuildState.DONE
	
	#call_deferred("")
	
	pass # Replace with function body.
	pass

# Called when the node enters the scene tree for the first time.
func _ready():
	display_mesh = MeshInstance3D.new()
	add_child(display_mesh)
	
	rd = RenderingServer.create_local_rendering_device()
	
	var image_load_thread = Thread.new()
	image_load_thread.start(func(): pass)

	mesh_build_tool	= MeshBuilderTool.new(self)
	pass # Replace with function body.


#var mutex:Mutex = Mutex.new()
#var thread_reload_image:Thread
#var thread_build_mesh:Thread
#var count:int = 0

class MeshBuilderTool extends RefCounted:
	signal done
	
	var thread:Thread
	var node:MarchingCubesViewerGlsl
	var flag_rebuild:bool = false
	var mutex:Mutex
	
	func _init(node:MarchingCubesViewerGlsl):
		self.node = node
		mutex = Mutex.new()
		thread = Thread.new()
		thread.start(main_loop)
	
	func rebuild():
		mutex.lock()
		flag_rebuild = true
		mutex.unlock()
		
	
	func main_loop():
		while true:
			mutex.lock()
			var needs_update:bool = flag_rebuild
			if needs_update:
				flag_rebuild = false
			mutex.unlock()
			
			if needs_update:
				node.build_mesh()
				done.emit()
			
			OS.delay_msec(100)
		
		pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if flag_reload_image_file:
		reload_image()
		flag_reload_image_file = false
		flag_update_mesh = true
		
		#mutex.lock()
		#if !thread_reload_image:
			#thread_reload_image = Thread.new()
			#thread_reload_image.start(reload_image)
			#await thread_reload_image.wait_to_finish()
		##mutex.unlock()
			#thread_reload_image = null
		#
		##reload_image()
			#flag_reload_image_file = false
			#flag_update_mesh = true
		
	#mutex.lock()
	
	if flag_update_mesh:
		mesh_build_tool.rebuild()
		flag_update_mesh = false
		
		#print("flag_update_mesh %d" % count)
		#count += 1
		#if mesh_build_state == BuildState.IDLE:
			#print("start thread")
			#flag_update_mesh = false
			#mesh_build_state = BuildState.BUILDING
			#thread_build_mesh = Thread.new()
			#thread_build_mesh.start(build_mesh)
			#pass
			#
	#if mesh_build_state == BuildState.DONE:
		#print("end thread")
		#thread_build_mesh.wait_to_finish()
		#thread_build_mesh = null
		#mesh_build_state = BuildState.IDLE
		
	#mutex.unlock()
		
		#if !thread_build_mesh:
			#print("start thread")
			#thread_build_mesh = Thread.new()
			#thread_build_mesh.start(build_mesh)
			#await thread_build_mesh.wait_to_finish()
			#thread_build_mesh = null
			#print("end thread")
			
#			flag_update_mesh = false
	pass
