@tool
extends EditorPlugin


func _enter_tree():
	add_custom_type("SmartInstance3D", "MeshInstance3D", preload("smartinstance3d.gd"), preload("mesh_icon.svg"))
	add_custom_type("SmartCSG3D", "CSGCombiner3D", preload("smartcsg3d.gd"), preload("csg_icon.svg"))
	add_custom_type("SmartCombine3D", "Node3D", preload("smartcombine3d.gd"), preload("combine_icon.svg"))
	add_custom_type("SmartArray3D", "MultiMeshInstance3D", preload("smartarray3d.gd"), preload("array_icon.svg"))


func _exit_tree():
	# Clean-up of the plugin goes here.
	remove_custom_type("SmartInstance3D")
	remove_custom_type("SmartCSG3D")
	remove_custom_type("SmartCombine3D")
	remove_custom_type("SmartArray3D")
