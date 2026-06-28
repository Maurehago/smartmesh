@tool
extends EditorNode3DGizmoPlugin

const HANDLE_X_KANTE = 0
const HANDLE_Z_KANTE = 1
const HANDLE_ECKE = 2

func _init() -> void:
	# Wir erstellen 3 verschiedene Materialien für bessere Übersicht im Editor
	create_handle_material("griff_rot")
	create_handle_material("griff_blau")
	create_handle_material("griff_weiss")
	
	# Optionale Hilfslinien-Farbe (Gelb)
	create_material("linien_material", Color(1, 1, 0, 0.8))

func _get_gizmo_name() -> String:
	return "KachelFlaecheAllInOneGizmo"

func _has_gizmo(node: Node) -> bool:
	return node is IAArray

func _redraw(gizmo: EditorNode3DGizmo) -> void:
	gizmo.clear()
	var node = gizmo.get_node_3d() as IAArray
	if not node or not node.is_inside_tree(): return

	var zelle_x = node.kachel_groesse.x + node.abstand.x
	var zelle_z = node.kachel_groesse.y + node.abstand.y
	
	var max_x = node.spalten * zelle_x
	var max_z = node.zeilen * zelle_z

	# Positionen für die 3 Griffe
	var pos_x_kante = Vector3(max_x, 0, max_z / 2.0)
	var pos_z_kante = Vector3(max_x / 2.0, 0, max_z)
	var pos_ecke = Vector3(max_x, 0, max_z)

	# 1. VISUELLE HILFSLINIEN ZEICHNEN (Zwingend nötig, damit Godot das Gizmo anzeigt!)
	# Wir zeichnen einen gelben Rahmen um die Außenkanten der aktuellen Fläche
	var linien_punkte = PackedVector3Array([
		Vector3(0, 0, 0), Vector3(max_x, 0, 0),
		Vector3(max_x, 0, 0), Vector3(max_x, 0, max_z),
		Vector3(max_x, 0, max_z), Vector3(0, 0, max_z),
		Vector3(0, 0, max_z), Vector3(0, 0, 0)
	])
	gizmo.add_lines(linien_punkte, get_material("linien_material", gizmo))

	# 2. GRIFFE EINZELN MIT IHREN FARBEN ÜBERGEBEN
	# Um unterschiedliche Materialien/Farben zu nutzen, übergeben wir sie nun einzeln an Godot
	gizmo.add_handles(PackedVector3Array([pos_x_kante]), get_material("griff_rot", gizmo), [HANDLE_X_KANTE])
	gizmo.add_handles(PackedVector3Array([pos_z_kante]), get_material("griff_blau", gizmo), [HANDLE_Z_KANTE])
	gizmo.add_handles(PackedVector3Array([pos_ecke]), get_material("griff_weiss", gizmo), [HANDLE_ECKE])

func _set_handle(gizmo: EditorNode3DGizmo, handle_id: int, secondary: bool, camera: Camera3D, screen_pos: Vector2) -> void:
	var node = gizmo.get_node_3d() as IAArray
	if not node: return

	# FIX: Wenn während des Ziehens die Griffe neu berechnet werden,
	# schützt uns dieser Check vor dem C++ Out-of-Bounds-Fehler
	if handle_id < 0 or handle_id > HANDLE_ECKE:
		return

	var strahl_start = camera.project_ray_origin(screen_pos)
	var strahl_richtung = camera.project_ray_normal(screen_pos)
	var ebene = Plane(Vector3.UP, node.global_position.y)
	var schnittpunkt = ebene.intersects_ray(strahl_start, strahl_richtung)
	
	if not schnittpunkt: return
	
	var lokale_maus_pos = node.global_transform.affine_inverse() * schnittpunkt
	var zelle_x = node.kachel_groesse.x + node.abstand.x
	var zelle_z = node.kachel_groesse.y + node.abstand.y

	# Umgehung des Fehlers: Wir lesen die Werte in temporäre Variablen ein,
	# anstatt die Live-Properties während der mathematischen Berechnung zu blockieren
	var aktuelle_spalten = node.spalten
	var aktuelle_zeilen = node.zeilen

	match handle_id:
		HANDLE_X_KANTE:
			var neue_spalten = int(floor((lokale_maus_pos.x / zelle_x) + 0.5))
			aktuelle_spalten = max(1, neue_spalten)
		HANDLE_Z_KANTE:
			var neue_zeilen = int(floor((lokale_maus_pos.z / zelle_z) + 0.5))
			aktuelle_zeilen = max(1, neue_zeilen)
		HANDLE_ECKE:
			var neue_spalten = int(floor((lokale_maus_pos.x / zelle_x) + 0.5))
			var neue_zeilen = int(floor((lokale_maus_pos.z / zelle_z) + 0.5))
			aktuelle_spalten = max(1, neue_spalten)
			aktuelle_zeilen = max(1, neue_zeilen)

	# Erst ganz am Ende weisen wir die berechneten Werte der Node zu.
	# Das verhindert asynchrone Sprünge im C++ Unterbau während des Ziehens.
	if node.spalten != aktuelle_spalten:
		node.spalten = aktuelle_spalten
	if node.zeilen != aktuelle_zeilen:
		node.zeilen = aktuelle_zeilen
