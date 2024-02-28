@tool
extends EditorPlugin


func _enter_tree():
	add_custom_type("MarchingCubesViewer", "Node3D", 
		preload("res://addons/marching_cubes_viewer/scenes/controls/glsl/marching_cubes_viewer_glsl.gd"), 
		preload("res://addons/marching_cubes_viewer/art/icons/marching_cubes_glsl_icon.svg"))
	pass


func _exit_tree():
	# Clean-up of the plugin goes here.
	remove_custom_type("MarchingCubesViewer")
	pass
