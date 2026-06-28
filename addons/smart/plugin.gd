@tool
extends EditorPlugin

var gizmo_plugin: EditorNode3DGizmoPlugin

func _enter_tree() -> void:
	gizmo_plugin = preload("res://addons/smart/ia_gizmo.gd").new()
	add_node_3d_gizmo_plugin(gizmo_plugin)

func _exit_tree() -> void:
	if gizmo_plugin:
		remove_node_3d_gizmo_plugin(gizmo_plugin)
