@tool
extends EditorNode3DGizmoPlugin

# IDs für alle 6 Richtungen
const HANDLE_POS_X = 0
const HANDLE_NEG_X = 1
const HANDLE_POS_Y = 2
const HANDLE_NEG_Y = 3
const HANDLE_POS_Z = 4
const HANDLE_NEG_Z = 5
var ids = [HANDLE_POS_X, HANDLE_NEG_X, HANDLE_POS_Y, HANDLE_NEG_Y, HANDLE_POS_Z, HANDLE_NEG_Z]


func _init() -> void:
	create_material("linien_farbe", Color(1, 1, 0, 0.6))
	create_handle_material("griff_farbe")

func _get_gizmo_name() -> String:
	return "MeshSubgizmoEditor"

func _has_gizmo(node: Node) -> bool:
	return node is Smart3D

# Hilfsfunktion, um zu prüfen, ob die Node ausgewählt ist
func _is_node_selected(node: Node3D) -> bool:
	var selection = EditorInterface.get_selection().get_selected_nodes()
	return node in selection

func _get_handle_name(gizmo: EditorNode3DGizmo, handle_id: int, secondary: bool) -> String:
	match handle_id:
		HANDLE_POS_X: return "Breite + (X)"
		HANDLE_NEG_X: return "Breite - (X)"
		HANDLE_POS_Y: return "Höhe + (Y)"
		HANDLE_NEG_Y: return "Höhe - (Y)"
		HANDLE_POS_Z: return "Tiefe + (Z)"
		HANDLE_NEG_Z: return "Tiefe - (Z)"
	return "Griff"

func _get_handle_value(gizmo: EditorNode3DGizmo, handle_id: int, secondary: bool) -> Variant:
	var node = gizmo.get_node_3d() as Smart3D
	if not node: return 0.0
	match handle_id:
		HANDLE_POS_X, HANDLE_NEG_X: return node.size_x
		HANDLE_POS_Y, HANDLE_NEG_Y: return node.size_y
		HANDLE_POS_Z, HANDLE_NEG_Z: return node.size_z
	return 0.0

func _redraw(gizmo: EditorNode3DGizmo) -> void:
	gizmo.clear()
	var node = gizmo.get_node_3d() as Smart3D
	if not node: return
	if not _is_node_selected(node):
		return

	# Wenn wir ziehen, nutzen wir die temporäre Größe und das temporäre Offset
	var mx = node._temp_size.x if node._temp_size.x >= 0 else node.size_x
	var my = node._temp_size.y if node._temp_size.y >= 0 else node.size_y
	var mz = node._temp_size.z if node._temp_size.z >= 0 else node.size_z
	
	var offset = node._temp_offset if node._temp_size.x >= 0 else Vector3.ZERO

	var hx = mx / 2.0
	var hy = my / 2.0
	var hz = mz / 2.0

	# Drahtgitter-Box zeichnen (inklusive dem temporären Offset während des Ziehens!)
	var linien = PackedVector3Array([
		Vector3(-hx,-hy,-hz) + offset, Vector3(hx,-hy,-hz) + offset, Vector3(hx,-hy,-hz) + offset, Vector3(hx,-hy,hz) + offset,
		Vector3(hx,-hy,hz) + offset, Vector3(-hx,-hy,hz) + offset, Vector3(-hx,-hy,hz) + offset, Vector3(-hx,-hy,-hz) + offset,
		Vector3(-hx,hy,-hz) + offset, Vector3(hx,hy,-hz) + offset, Vector3(hx,hy,-hz) + offset, Vector3(hx,hy,hz) + offset,
		Vector3(hx,hy,hz) + offset, Vector3(-hx,hy,hz) + offset, Vector3(-hx,hy,hz) + offset, Vector3(-hx,hy,-hz) + offset,
		Vector3(-hx,-hy,-hz) + offset, Vector3(-hx,hy,-hz) + offset, Vector3(hx,-hy,-hz) + offset, Vector3(hx,hy,-hz) + offset,
		Vector3(hx,-hy,hz) + offset, Vector3(hx,hy,hz) + offset, Vector3(-hx,-hy,hz) + offset, Vector3(-hx,hy,hz) + offset
	])
	gizmo.add_lines(linien, get_material("linien_farbe", gizmo))

	# Positionen für alle 6 Griffe wandern mit dem Offset mit
	var griffe = PackedVector3Array([
		Vector3(hx, 0, 0) + offset,   # POS_X
		Vector3(-hx, 0, 0) + offset,  # NEG_X
		Vector3(0, hy, 0) + offset,   # POS_Y
		Vector3(0, -hy, 0) + offset,  # NEG_Y
		Vector3(0, 0, hz) + offset,   # POS_Z
		Vector3(0, 0, -hz) + offset    # NEG_Z
	])
	
	var ids = [HANDLE_POS_X, HANDLE_NEG_X, HANDLE_POS_Y, HANDLE_NEG_Y, HANDLE_POS_Z, HANDLE_NEG_Z]
	gizmo.add_handles(griffe, get_material("griff_farbe", gizmo), ids)

func _set_handle(gizmo: EditorNode3DGizmo, handle_id: int, secondary: bool, camera: Camera3D, screen_pos: Vector2) -> void:
	var node = gizmo.get_node_3d() as Smart3D
	if not node: return

	var ray_origin = camera.project_ray_origin(screen_pos)
	var ray_dir = camera.project_ray_normal(screen_pos)

	var axis_x = node.global_transform.basis.x.normalized()
	var axis_y = node.global_transform.basis.y.normalized()
	var axis_z = node.global_transform.basis.z.normalized()

	var ebenen_normale = Vector3.UP
	match handle_id:
		HANDLE_POS_X, HANDLE_NEG_X: ebenen_normale = axis_y if abs(ray_dir.dot(axis_y)) > abs(ray_dir.dot(axis_z)) else axis_z
		HANDLE_POS_Y, HANDLE_NEG_Y: ebenen_normale = axis_x if abs(ray_dir.dot(axis_x)) > abs(ray_dir.dot(axis_z)) else axis_z
		HANDLE_POS_Z, HANDLE_NEG_Z: ebenen_normale = axis_x if abs(ray_dir.dot(axis_x)) > abs(ray_dir.dot(axis_y)) else axis_y

	var ebene = Plane(ebenen_normale, node.global_position)
	var schnittpunkt_welt = ebene.intersects_ray(ray_origin, ray_dir)
	if schnittpunkt_welt == null: return

	var neue_pos_lokal = node.global_transform.affine_inverse() * schnittpunkt_welt

	if node._temp_size.x < 0:
		node._temp_size = Vector3(node.size_x, node.size_y, node.size_z)
		node._temp_offset = Vector3.ZERO

	# Berechne die neue stufenlose Größe und das lokale Offset GLEICHZEITIG
	# clampf(wert, min, max) sorgt dafür, dass die Box nie kleiner als 0.01 und nie größer als 8.0 wird.
	match handle_id:
		HANDLE_POS_X:
			node._temp_size.x = clampf(neue_pos_lokal.x * 2.0, 0.01, 8.0)
			node._temp_offset.x = (node._temp_size.x - node.size_x) / 2.0
		HANDLE_NEG_X:
			node._temp_size.x = clampf(-neue_pos_lokal.x * 2.0, 0.01, 8.0)
			node._temp_offset.x = -((node._temp_size.x - node.size_x) / 2.0)
			
		HANDLE_POS_Y:
			node._temp_size.y = clampf(neue_pos_lokal.y * 2.0, 0.01, 8.0)
			node._temp_offset.y = (node._temp_size.y - node.size_y) / 2.0
		HANDLE_NEG_Y:
			node._temp_size.y = clampf(-neue_pos_lokal.y * 2.0, 0.01, 8.0)
			node._temp_offset.y = -((node._temp_size.y - node.size_y) / 2.0)
			
		HANDLE_POS_Z:
			node._temp_size.z = clampf(neue_pos_lokal.z * 2.0, 0.01, 8.0)
			node._temp_offset.z = (node._temp_size.z - node.size_z) / 2.0
		HANDLE_NEG_Z:
			node._temp_size.z = clampf(-neue_pos_lokal.z * 2.0, 0.01, 8.0)
			node._temp_offset.z = -((node._temp_size.z - node.size_z) / 2.0)

	node.update_gizmos()
	
# WIRD AUTOMATISCH BEIM LOSLASSEN DER MAUS AUFGERUFEN
func _commit_handle(gizmo: EditorNode3DGizmo, handle_id: int, secondary: bool, restore: Variant, cancel: bool) -> void:
	var node = gizmo.get_node_3d() as Smart3D
	if not node or node._temp_size.x < 0: return

	var schritt = 0.1
	if "snapping" in node:
		schritt = (node.snapping).to_float()

	# Das finale Einrasten auf das Raster
	var finale_groesse = node._temp_size
	finale_groesse.x = max(schritt, snapped(finale_groesse.x, schritt))
	finale_groesse.y = max(schritt, snapped(finale_groesse.y, schritt))
	finale_groesse.z = max(schritt, snapped(finale_groesse.z, schritt))

	var axis_x = node.global_transform.basis.x.normalized()
	var axis_y = node.global_transform.basis.y.normalized()
	var axis_z = node.global_transform.basis.z.normalized()

	# Jetzt verschieben wir den echten Node final basierend auf der gerundeten Größe
	match handle_id:
		HANDLE_POS_X: node.global_position += axis_x * ((finale_groesse.x - node.size_x) / 2.0)
		HANDLE_NEG_X: node.global_position -= axis_x * ((finale_groesse.x - node.size_x) / 2.0)
		HANDLE_POS_Y: node.global_position += axis_y * ((finale_groesse.y - node.size_y) / 2.0)
		HANDLE_NEG_Y: node.global_position -= axis_y * ((finale_groesse.y - node.size_y) / 2.0)
		HANDLE_POS_Z: node.global_position += axis_z * ((finale_groesse.z - node.size_z) / 2.0)
		HANDLE_NEG_Z: node.global_position -= axis_z * ((finale_groesse.z - node.size_z) / 2.0)

	# Echte Werte schreiben
	node.size_x = finale_groesse.x
	node.size_y = finale_groesse.y
	node.size_z = finale_groesse.z

	# Alles zurücksetzen
	node._temp_size = Vector3(-1, -1, -1)
	node._temp_offset = Vector3.ZERO
	node.update_gizmos()
# WICHTIG: Damit _redraw() während des Ziehens die gelbe Box richtig anzeigt,
# müssen wir dort die temporäre Variable bevorzugen!
