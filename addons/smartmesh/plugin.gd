@tool
extends EditorPlugin

var inspector_plugin: EditorInspectorPlugin

func _enter_tree() -> void:
	#inspector_plugin = preload("res://addons/smartmesh/smart_inspector_plugin.gd").new()
	#add_inspector_plugin(inspector_plugin)
	pass
	
func _exit_tree() -> void:
	#remove_inspector_plugin(inspector_plugin)
	pass



#func _enter_tree():
	## Panel erstellen
	#dock = preload("res://addons/smartmesh/panel.tscn").instantiate()
	#
	## Anzeigen
	#add_control_to_dock(EditorPlugin.DOCK_SLOT_RIGHT_UL, dock)
	##add_custom_type("SmartInstance3D", "MeshInstance3D", preload("smartinstance3d.gd"), preload("mesh_icon.svg"))
	##add_custom_type("SmartCSG3D", "CSGCombiner3D", preload("smartcsg3d.gd"), preload("csg_icon.svg"))
	##add_custom_type("SmartCombine3D", "Node3D", preload("smartcombine3d.gd"), preload("combine_icon.svg"))
	##add_custom_type("SmartArray3D", "MultiMeshInstance3D", preload("smartarray3d.gd"), preload("array_icon.svg"))
#
#
#func _exit_tree():
	## Dock entfernen
	#remove_control_from_docks(dock)
	#dock.free()
	#
	## Clean-up of the plugin goes here.
	##remove_custom_type("SmartInstance3D")
	##remove_custom_type("SmartCSG3D")
	##remove_custom_type("SmartCombine3D")
	##remove_custom_type("SmartArray3D")
