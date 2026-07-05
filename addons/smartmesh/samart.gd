@tool
extends Object
class_name Smart

static var BASE_PATH = "res://addons/smartmesh/mesh/"
static var BASE_MATERIAL:Material = load("res://addons/smartmesh/vertex_material.material")

# Farben Arrays [0-71]
static var BASE_COLORS:PackedColorArray = [
	Color8(255,255,255) #9
	, Color8(245,245,245) #1,1
	, Color8(228,228,228) #2,1
	, Color8(206,206,206) #3,1
	, Color8(177,177,177) #4,1
	, Color8(142,142,142) #5,1
	, Color8(102,102,102) #6,1
	, Color8(62,62,62) #7,1
	, Color8(31,31,31) #8,1
	, Color8(0,0,0) #9,1
	, Color8(255,0,0) #9,2	
	, Color8(251,180,161) #1,2
	, Color8(220,90,58) #2,2
	, Color8(171,58,29) #3,2
	, Color8(126,26,9) #4,2
	, Color8(255,198,76) #1,3
	, Color8(253,160,0) #2,3
	, Color8(240,121,0) #3,3
	, Color8(198,86,0) #4,3
	, Color8(0,255,0) #9,3
	, Color8(211,233,166) #5,2
	, Color8(156,188,98) #6,2
	, Color8(102,145,50) #7,2
	, Color8(54,91,19) #8,2
	, Color8(120,254,122) #5,3
	, Color8(53,231,29) #6,3
	, Color8(26,151,9) #7,3
	, Color8(11,76,2) #8,3
	, Color8(0,0,255) #9,4
	, Color8(193,234,255) #1,6
	, Color8(142,198,226) #2,6
	, Color8(75,147,184) #3,6
	, Color8(24,86,118) #4,6
	, Color8(120,180,254) #1,7
	, Color8(44,138,251) #2,7
	, Color8(10,97,203) #3,7
	, Color8(3,50,106) #4,7
	, Color8(255,255,0) #9,5
	, Color8(249,243,166) #5,6
	, Color8(248,227,31) #6,6
	, Color8(223,183,10) #7,6
	, Color8(175,144,0) #8,6
	, Color8(255,0,255) #9,6
	, Color8(246,218,248) #1,4
	, Color8(239,168,245) #2,4
	, Color8(229,84,243) #3,4
	, Color8(173,7,189) #4,4
	, Color8(211,175,247) #1,5
	, Color8(164,101,226) #2,5
	, Color8(125,58,191) #3,5
	, Color8(72,11,131) #4,5
	, Color8(0,255,255) #9,7
	, Color8(196,217,255) #1,8
	, Color8(151,176,186) #2,8
	, Color8(101,120,127) #3,8
	, Color8(55,66,71) #4,8
	, Color8(248,213,201) #5,7
	, Color8(241,188,169) #6,7
	, Color8(217,161,123) #7,7
	, Color8(190,145,108) #8,7
	, Color8(255,217,193) #5,8
	, Color8(247,191,177) #6,8
	, Color8(214,162,163) #7,8
	, Color8(140,102,125) #8,8
	, Color8(217,185,157) #5,4
	, Color8(189,151,117) #6,4
	, Color8(146,104,66) #7,4
	, Color8(101,69,29) #8,4
	, Color8(123,91,65) #5,5
	, Color8(98,62,43) #6,5
	, Color8(67,40,26) #7,5
	, Color8(37,22,10) #8,5
]


# ================================
#   Materials
# ------------

static var boxMesh:BoxMesh

## Liefert eine der Grundfarben "schwarz", "rot", "grün", "blau", "gelb", "lila", "türkies", "weiß" zurück.
## Diese werden für einen Shader sum Maskieren des Materials genutzt.
static func get_mask_color(color_mask: int) -> Color:
	match color_mask:
		0:
			return Color(0,0,0)
		1:
			return Color(1,0,0)
		2:
			return Color(0,1,0)
		3:
			return Color(0,0,1)
		4:
			return Color(1,1,0)
		5:
			return Color(1,0,1)
		6:
			return Color(0,1,1)
		7:
			return Color(1,1,1)
	
	return Color()

# ================================
#   Meshes
# -----------

## Erstellt aus einem Mesh ein SmartMesh
## Die Vertex Farben bestimmen die Vertex Gruppen (Basis Farben, wie bei get Mask Color) max 8 Gruppen möglich
static func mesh_to_smartmesh(source_mesh:Mesh) -> SmartMesh:
	# Lesen der Mesh-Arrays vom Surface 0
	var mesh_arrays = source_mesh.surface_get_arrays(0)
	var raw_vertices: PackedVector3Array = mesh_arrays[Mesh.ARRAY_VERTEX]
	var raw_normals:PackedVector3Array = mesh_arrays[Mesh.ARRAY_NORMAL]
	var raw_colors: PackedColorArray = mesh_arrays[Mesh.ARRAY_COLOR] if mesh_arrays[Mesh.ARRAY_COLOR] else []
	
	# Initialisierung der Ziel-Ressource
	var target_mesh:SmartMesh = SmartMesh.new()
	target_mesh.vertices = raw_vertices
	target_mesh.normals = raw_normals
	target_mesh.indices = mesh_arrays[Mesh.ARRAY_INDEX]
	target_mesh.base_size = source_mesh.get_aabb().size
	target_mesh.vertex_group.clear()

	# nur wenn Farben aus dem Mesh gelesen werden
	if !raw_colors.is_empty():
		for i in range(raw_vertices.size()):
			if raw_colors[i].r == 0.0 and raw_colors[i].g == 0.0 and raw_colors[i].b == 0.0:
				var gruppe = target_mesh.get_group("0")
				gruppe.append(i)
			elif raw_colors[i].r > 0.0 and raw_colors[i].g == 0.0 and raw_colors[i].b == 0.0:
				var gruppe = target_mesh.get_group("1")
				gruppe.append(i)
			elif raw_colors[i].r == 0.0 and raw_colors[i].g > 0.0 and raw_colors[i].b == 0.0:
				var gruppe = target_mesh.get_group("2")
				gruppe.append(i)
			elif raw_colors[i].r == 0.0 and raw_colors[i].g == 0.0 and raw_colors[i].b > 0.0:
				var gruppe = target_mesh.get_group("3")
				gruppe.append(i)
			elif raw_colors[i].r > 0.0 and raw_colors[i].g > 0.0 and raw_colors[i].b == 0.0:
				var gruppe = target_mesh.get_group("4")
				gruppe.append(i)
			elif raw_colors[i].r > 0.0 and raw_colors[i].g == 0.0 and raw_colors[i].b > 0.0:
				var gruppe = target_mesh.get_group("5")
				gruppe.append(i)
			elif raw_colors[i].r == 0.0 and raw_colors[i].g > 0.0 and raw_colors[i].b > 0.0:
				var gruppe = target_mesh.hole_gruppe("6")
				gruppe.append(i)
			elif raw_colors[i].r > 0.0 and raw_colors[i].g > 0.0 and raw_colors[i].b > 0.0:
				var gruppe = target_mesh.get_group("7")
				gruppe.append(i)

	# SmartMesh zurückgeben
	return target_mesh


## Lädt alle .tres-Bauteile aus einem Ordner in ein Dictionary
static func load_smartdata_list(ordner_pfad: String = "res://bauteile/") -> Dictionary:
	var geladene_bauteile: Dictionary = {}
	var dir = DirAccess.open(ordner_pfad)
	
	if dir:
		dir.list_dir_begin()
		var datei_name = dir.get_next()
		
		while datei_name != "":
			# Stelle sicher, dass wir nur .tres (oder im Export .remap/.gdc) Dateien lesen
			# Hinweis: Godot konvertiert .tres beim Exportieren manchmal intern. 
			# .get_extension() fängt das ab.
			if not dir.current_is_dir() and (datei_name.ends_with(".tres") or datei_name.ends_with(".tres.remap")):
				# Bereinige den Dateinamen für den Loader (entferne .remap falls vorhanden)
				var bereinigter_name = datei_name.replace(".remap", "")
				var voller_pfad = ordner_pfad + bereinigter_name
				
				var res = ResourceLoader.load(voller_pfad)
				if res is SmartMesh:
					# Nutze den reinen Namen ohne ".tres" als Key im Dictionary
					var key_name = bereinigter_name.get_basename()
					geladene_bauteile[key_name] = res
					
			datei_name = dir.get_next()
		dir.list_dir_end()
		
	print("Es wurden %d Bauteile geladen." % geladene_bauteile.size())
	return geladene_bauteile
	

# Hilfsfunktion, die alle Dateinamen (MeshIDs) aus einem spezifischen Unterordner holt
# Holt die Ressourcen und gibt sie inklusive Unterordner zurück!
static func get_resources_for_group(group_name: String) -> PackedStringArray:
	var result := PackedStringArray()
	var ordner_pfad = BASE_PATH + group_name + "/"
	
	if not DirAccess.dir_exists_absolute(ordner_pfad):
		return result
		
	var dir = DirAccess.open(ordner_pfad)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if not dir.current_is_dir() and file_name.ends_with(".tres"):
				# Hier kombinieren wir Gruppen-Ordner und Dateiname!
				# Ergebnis: "tisch_platten/holz_platte_01"
				var kombinierte_id = group_name + "/" + file_name.get_basename()
				result.append(kombinierte_id)
			file_name = dir.get_next()
		dir.list_dir_end()
	
	return result



# ================================
#   Objects
# -----------

## Liefert ein SmartObjekt mit angegebener Größe zurück
static func calc_size(container_size:Vector3, color_number:float = 0) -> SmartObject:
	var obj = SmartObject.new()
	obj.size = container_size
	obj.color_number = color_number
	return obj


## Fügt die Elemente aus 'list_to_append' an 'base_list' an. 'base_list' wird dabei direkt modifiziert.
static func append_smartObjects(base_list: Array[SmartObject], list_to_append: Array[SmartObject], offset:Vector3 = Vector3.ZERO, mesh_id:int = 0) -> void:
	# Durchfahre alle Elemente der Vorlagen-Liste
	for element in list_to_append:
		if not element: 
			continue
		
		# Element duplizieren, damit es eine eigene Identität bekommt
		var new_element = element.duplicate(true) as SmartObject
		
		# Position um den aktuellen Versatz verschieben
		new_element.pos += offset
		
		# Mesh_number setzen
		new_element.mesh_number = mesh_id
		
		# Direkt an die existierende Basis-Liste anhängen
		base_list.append(new_element)


## direction: z.B. Vector3.RIGHT (X+), Vector3(1, 1, 0) (Ecke oben rechts)
## mode: 1 für Außen, -1 für Innen, 0 für Mitte
## margin: Optionaler Zusatzabstand in Einheiten
static func calc_offset(container_size: Vector3, object_size: Vector3, direction: Vector3, mode: int, margin: float = 0.0) -> SmartObject:
	var offset = Vector3.ZERO
	var obj = SmartObject.new()
	obj.size = object_size
	
	# Wir loopen über x, y und z
	for axis in [Vector3.RIGHT, Vector3.UP, Vector3.FORWARD]:
		# Prüfen, ob die Achse in der Richtung enthalten ist (1 oder -1)
		var d = direction.dot(axis)
		
		if abs(d) > 0.01: # Falls diese Achse Teil der Ausrichtung ist
			var radius_a = container_size.dot(axis) / 2.0
			var radius_b = object_size.dot(axis) / 2.0
			
			# Formel: (Radius_A + (Modus * Radius_B) + Abstand) * Richtungssign
			var dist = (radius_a + (mode * radius_b) + margin) * sign(d)
			offset += axis * dist
	
	obj.pos = offset
	return obj

## direction: Achse der Verteilung (z.B. Vector3.RIGHT)
## count: Anzahl der Elemente
## touch_edges: true = bündig an Innenkante (Leiter), false = mit Abstand zum Rand (Zaun)
static func calc_linear_array(container_size: Vector3, object_size: Vector3, direction: Vector3, count: int, touch_edges: bool = true) -> Array[SmartObject]:
	var list: Array[SmartObject] = []
	if count <= 0: return list
	
	var axis = direction.normalized()
	var full_dist = container_size.dot(axis)
	var obj_dist = object_size.dot(axis)

	if count == 1:
		var obj = SmartObject.new()
		obj.size = object_size
		obj.pos = Vector3.ZERO
		list.append(obj)
		return list

	var start_pos: float
	var step: float

	if touch_edges:
		# Bündig: Erstes und letztes Objekt berühren die Innenwand
		# Platz zwischen den Mittelpunkten der äußeren Objekte
		var available_range = full_dist - obj_dist
		step = available_range / (count - 1)
		start_pos = -available_range / 2.0
	else:
		# Mit Abstand: Randabstand entspricht dem Abstand zwischen den Objekten
		# (Wie bei Zaunlatten, die nicht die Pfosten berühren)
		step = full_dist / count
		start_pos = (-full_dist / 2.0) + (step / 2.0)

	for i in range(count):
		var obj = SmartObject.new()
		obj.size = object_size
		obj.pos = axis * (start_pos + i * step)
		list.append(obj)
		#positions.append(axis * (start_pos + i * step))
		
	return list


## Linar Array mi´t Random Versatz
static func calc_random_size_pos(count:int, linear_pos:Vector3, random_pos:Vector3, random_scale:Vector3, random_rotation:Vector3) -> Array[SmartObject]:
	var list: Array[SmartObject] = []
	# Position
	var pos:Vector3 = Vector3.ZERO

	for i in range(count):
		# neues Objekt
		var obj = SmartObject.new()
		
		# Skalierung
		obj.size = Vector3(1.0, 1.0, 1.0)
		obj.size.x = randf_range(1.0-random_scale.x, 1.0+random_scale.x)
		obj.size.y = randf_range(1.0-random_scale.y, 1.0+random_scale.y)
		obj.size.z = randf_range(1.0-random_scale.z, 1.0+random_scale.z)
		

		# Rotation
		obj.rotate = Vector3.ZERO
		obj.rotate.x = randf_range(-random_rotation.x, +random_rotation.x)
		obj.rotate.y = randf_range(-random_rotation.y, +random_rotation.y)
		obj.rotate.z = randf_range(-random_rotation.z, +random_rotation.z)
		
		# Basis() Berechnung
		#rand_basis = Basis.from_euler(obj.rotate) * obj.size

		# Position
		if i > 0 and i < count -1:
			obj.pos = Vector3.ZERO
			obj.pos.x = randf_range(-1,1)*random_pos.x
			obj.pos.y = randf_range(-1,1)*random_pos.y
			obj.pos.z = randf_range(-1,1)*random_pos.z

		# zur Liste hinzufügen
		list.append(obj)
		pos += linear_pos
		
	return list

## Rahmen erstellen
## mode: 1 für Außen, -1 für Innen, 0 für Mitte
static func calc_border(container_size: Vector3, border_size: Vector2, mode:int = -1) -> Array[SmartObject]:
	var list: Array[SmartObject] = []
	var width = border_size.x
	var deph = border_size.y
	
	var size_h = Vector3(container_size.x - (2*width), width, deph)
	list.append(Smart.calc_offset(container_size, size_h, Vector3.UP, mode))
	list.append(Smart.calc_offset(container_size, size_h, Vector3.DOWN, mode))
	
	var size_v = Vector3(width, container_size.y, deph)
	list.append(Smart.calc_offset(container_size, size_v, Vector3.LEFT, mode))
	list.append(Smart.calc_offset(container_size, size_v, Vector3.RIGHT, mode))
	
	return list

static func calc_rect_with_hole(wall: Rect2, hole: Rect2) -> Array[Rect2]:
	# Wenn sich beide nicht schneiden, bleibt die Wand intakt
	if not wall.intersects(hole):
		return [wall]
	
	# Schnittbereich eingrenzen (falls das Fenster über die Wand ragt)
	var clipped_hole = wall.intersection(hole)
	var sub_rects: Array[Rect2] = []
	
	# 1. LINKES TEILSTÜCK (Geht vertikal komplett durch)
	if clipped_hole.position.x > wall.position.x:
		var width = clipped_hole.position.x - wall.position.x
		sub_rects.append(Rect2(wall.position.x, wall.position.y, width, wall.size.y))
		
	# 2. RECHTES TEILSTÜCK (Geht vertikal komplett durch)
	if clipped_hole.end.x < wall.end.x:
		var width = wall.end.x - clipped_hole.end.x
		sub_rects.append(Rect2(clipped_hole.end.x, wall.position.y, width, wall.size.y))
		
	# 3. OBERES TEILSTÜCK (Exakt die Breite des (beschnittenen) Fensters)
	if clipped_hole.position.y > wall.position.y:
		var height = clipped_hole.position.y - wall.position.y
		sub_rects.append(Rect2(clipped_hole.position.x, wall.position.y, clipped_hole.size.x, height))
		
	# 4. UNTERES TEILSTÜCK (Exakt die Breite des (beschnittenen) Fensters)
	if clipped_hole.end.y < wall.end.y:
		var height = wall.end.y - clipped_hole.end.y
		sub_rects.append(Rect2(clipped_hole.position.x, clipped_hole.end.y, clipped_hole.size.x, height))
		
	return sub_rects

# Der Kern-Algorithmus angepasst an deine Ressourcen
#static func _split_3d_surface(surface_pos: Vector3, surface_size: Vector3, hole_resources: Array[RoomElementResource]) -> Array[AABB]:
static func split_3d_surface(container:SmartObject, holes: Array[SmartObject], axis_width:int = 0, axis_height:int = 1, axis_thickness:int = 2) -> Array[SmartObject]:
	var surface_2d_size = Vector2(container.size[axis_width], container.size[axis_height])
	var surface_2d = Rect2(-surface_2d_size / 2.0, surface_2d_size)
	
	var holes_2d: Array[Rect2] = []
	for hole in holes:
		if not hole: continue
		var local_pos_3d = hole.pos - container.pos
		var hole_2d_center = Vector2(local_pos_3d[axis_width], local_pos_3d[axis_height])
		var hole_2d_size = Vector2(hole.size[axis_width], hole.size[axis_height])
		holes_2d.append(Rect2(hole_2d_center - (hole_2d_size / 2.0), hole_2d_size))
	
	# Iterative Aufteilung
	var current_rects: Array[Rect2] = [surface_2d]
	for hole in holes_2d:
		var next_rects: Array[Rect2] = []
		for rect in current_rects:
			if rect.intersects(hole):
				next_rects.append_array(calc_rect_with_hole(rect, hole))
			else:
				next_rects.append(rect)
		current_rects = next_rects
	
	# Zurück in 3D (SmartObject) konvertieren
	var final_3d_boxes: Array[SmartObject] = []
	var thickness = container.size[axis_thickness]
	
	for rect in current_rects:
		var rect_center_2d = rect.position + (rect.size / 2.0)
		var new_obj = SmartObject.new()
		new_obj.color_number = container.color_number
		new_obj.mesh_id = container.mesh_id
		new_obj.pos = container.pos
		new_obj.pos[axis_width] += rect_center_2d.x
		new_obj.pos[axis_height] += rect_center_2d.y
		new_obj.target_forward = container.target_forward
		new_obj.target_up = container.target_up
		#var block_center_3d = surface.pos
		#block_center_3d[axis_width] += rect_center_2d.x
		#block_center_3d[axis_height] += rect_center_2d.y
		
		new_obj.size[axis_width] = rect.size.x
		new_obj.size[axis_height] = rect.size.y
		new_obj.size[axis_thickness] = thickness
		#var block_size_3d = Vector3.ZERO
		#block_size_3d[axis_width] = rect.size.x
		#block_size_3d[axis_height] = rect.size.y
		#block_size_3d[axis_thickness] = thickness
		
		final_3d_boxes.append(new_obj)
		
	return final_3d_boxes




#var wall_pos = Vector3(0, 2, 0) # Mitte der Wand auf 2m Höhe
#var wall_size = Vector3(10, 4, 0.3) # 10m lang, 4m hoch, 30cm dick
#
#var holes = [
	#{"position": Vector3(-2, 2, 0), "size": Vector3(1.5, 1.5, 0.5)}, # Fenster 1
	#{"position": Vector3(2, 2, 0), "size": Vector3(1.5, 1.5, 0.5)}   # Fenster 2
#]
#
## Achsen: Breite=0 (X), Höhe=1 (Y), Dicke=2 (Z)
#var wall_blocks = split_3d_surface(wall_pos, wall_size, holes, 0, 1, 2)


## SurfaceTool aus Liste mit SmartObject erstellen
#static func create_surfacetool(smartboxes: Array[SmartObject], st:SurfaceTool = null) -> SurfaceTool:
	## Surfacetool zum zusammenbauen
	##var st = SurfaceTool.new()
	#if !st:
		#st = SurfaceTool.new()
		#st.begin(Mesh.PRIMITIVE_TRIANGLES)
	#
	## alle Smat Boxen durchgehen
	#for box in smartboxes:
		#var m
		#var basis = Basis() # kann Später Skaliert und rotiert werden
		#
		## Je nach MeshType ein Mesh erzeugen
		#match box.mesh_type:
			#"box":
				#if !boxMesh: boxMesh = BoxMesh.new()
				#m = boxMesh
				#m.size = box.size
		#
		## Farbe setzen und Mesch hinzufügen
		#st.set_color(get_mask_color(box.color_mask))
		#st.append_from(m, 0, Transform3D(basis, box.pos))
	#
	#return st
#
## Mesh aus Liste mit SmartObjecten erstellen
#static func create_mesh(smartboxes: Array[SmartObject], mesh: ArrayMesh = null, st:SurfaceTool = null) -> ArrayMesh:
	## Mesh prüfen
	#if !mesh: mesh = ArrayMesh.new()
	#
	## Surfacetool zusammenbauen
	#st = create_surfacetool(smartboxes, st)
#
	#mesh.clear_surfaces()
	#return st.commit(mesh)

## VertexPunkte Skalieren
static func change_vertex_scale(vertices: PackedVector3Array, source_size: Vector3, target_size: Vector3, save_area: Vector3) -> PackedVector3Array:
	if vertices.is_empty(): return vertices
	#var vertices:PackedVector3Array = base_vertices.duplicate()

	# Berechne globalen Skalierungsfaktor (Vermeide Division durch 0)
	var scale_x = target_size.x / source_size.x if source_size.x > 0 else 1.0
	var scale_y = target_size.y / source_size.y if source_size.y > 0 else 1.0
	var scale_z = target_size.z / source_size.z if source_size.z > 0 else 1.0
	var scale_factor = Vector3(scale_x, scale_y, scale_z)

	# eine Transformation, die NUR skaliert
	var transform = Transform3D().scaled(scale_factor)
	
	# Der *-Operator multipliziert das GESAMTE Array direkt im C++ Code.
	# Das ist extrem schnell und benötigt keine GDScript-Schleife!
	return transform * vertices


## Vertex Array Punkte verschieben
static func change_vertex_size(base_vertices: PackedVector3Array, source_size: Vector3, target_size: Vector3, save_area: Vector3) -> PackedVector3Array:
	if base_vertices.is_empty(): return base_vertices
	var vertices:PackedVector3Array = base_vertices.duplicate()
	
	# Grenze der Schutzzone (Radius vom Nullpunkt)
	var safe_limit = save_area / 2.0
	
	# Fester Betrag, um den die äußeren Punkte verschoben werden müssen
	var offset = (target_size - source_size) / 2.0
	
	# Schleife optimiert für Godot: Direkte Modifikation im Array
	for i in range(vertices.size()):
		var v:Vector3 = vertices[i]
		
		# X-Achse starr verschieben, wenn außerhalb der Schutzzone
		if abs(v.x) > safe_limit.x:
			v.x += sign(v.x) * offset.x
			
		# Y-Achse starr verschieben, wenn außerhalb der Schutzzone
		if abs(v.y) > safe_limit.y:
			v.y += sign(v.y) * offset.y
			
		# Z-Achse starr verschieben, wenn außerhalb der Schutzzone
		if abs(v.z) > safe_limit.z:
			v.z += sign(v.z) * offset.z
			
		vertices[i] = v
		
	return vertices


## Erstellt ein Farb-Array 
static func generate_color_array(vertex_count: int, color_number: int) -> PackedColorArray:
	var colors := PackedColorArray()
	colors.resize(vertex_count) # Speicher auf einmal reservieren
	colors.fill(BASE_COLORS[color_number])        # Alle Elemente nativ mit der Farbe füllen
	return colors


static func get_smartmesh(id:String) -> SmartMesh:
	# Pfad zusammenbauen
	var res_pfad = BASE_PATH + id + ".tres"
	
	if ResourceLoader.exists(res_pfad):
		return load(res_pfad)
	
	return null


## Mesh von SmartObject und SmartMesh erzeugen
static func smart_to_mesh(smartboxes: Array[SmartObject], mesh: ArrayMesh = null, smart_mesh:SmartMesh = null) -> ArrayMesh:
	# Mesh prüfen
	if !mesh: mesh = ArrayMesh.new()

	# Neues SmartMesh
	var sm:SmartMesh = SmartMesh.new()

	# Liste mit Farben
	var colors:PackedColorArray = []

	# debug
	#print("SmartBoxes[0].size:", smartboxes[0].size)

	# alle Smart Boxen durchgehen
	for box in smartboxes:
		# Wenn keine mesh_id
		if !box.mesh_id:
			continue # nächste box

		# Smart Mesh zum Hinzufügen laden
		var box_mesh:SmartMesh
		if smart_mesh != null:
			box_mesh = smart_mesh
		else:
			box_mesh = get_smartmesh(box.mesh_id)
		if !box_mesh:
			continue # nächste Box
		
		# 1. Rotations-Basis berechnen
		var rotation_basis: Basis = Basis.looking_at(box.target_forward, box.target_up, false)
		
		var vertices: PackedVector3Array
		var normals: PackedVector3Array
		
		# Wenn Vertex Verschiebung
		if box_mesh.is_vertex_scale:
			# WICHTIG: Wir transformieren die box.size INVERS zur Rotation.
			# Dadurch wird die Box-Größe so hingedreht, dass sie zum originalen, ungedrehten Mesh passt!
			# abs() verhindert negative Werte durch die Rotation.
			var local_target_size: Vector3 = (rotation_basis.inverse() * box.size).abs()

			# Vertices Verschiebung
			vertices = change_vertex_size(box_mesh.vertices, box_mesh.base_size, local_target_size, box_mesh.save_area)

			# Mesh richtig ausrichten
			var transform: Transform3D = Transform3D(rotation_basis, box.pos)
			vertices = transform * vertices
			normals = Transform3D(rotation_basis, Vector3.ZERO) * box_mesh.normals
			
		else:
			# Skalierung
			var scale_x = box.size.x / box_mesh.base_size.x if box_mesh.base_size.x > 0 else 1.0
			var scale_y = box.size.y / box_mesh.base_size.y if box_mesh.base_size.y > 0 else 1.0
			var scale_z = box.size.z / box_mesh.base_size.z if box_mesh.base_size.z > 0 else 1.0
			var scale_factor = Vector3(scale_x, scale_y, scale_z)
			
			# WICHTIG: immer um Vector3.ZERO skalieren, und nicht die box.pos nehmen sonnst wird die box.pos auch skaliert
			var transform: Transform3D = Transform3D(rotation_basis, Vector3.ZERO)
			transform = transform.scaled(scale_factor)
			
			# Position jetz nachträglich setzen
			transform.origin = box.pos
			
			# Drehen Skalieren und Verschieben
			vertices = transform * box_mesh.vertices
			
			# Positionieren
			#for i in range(vertices.size()):
			#	vertices[i] += box.pos
			
			# Normalen richtig stellen
			var normal_basis: Basis = rotation_basis.inverse().transposed()
			normals = Transform3D(normal_basis, Vector3.ZERO) * box_mesh.normals
		
		if vertices.size() <= 0:
			continue
		
		# Indizes korrigieren: Teil 2 muss um die Länge von Teil 1 verschoben werden
		# Alte größe zum Verschieben merken
		var index_offset: int = sm.vertices.size()
		var new_indices := PackedInt32Array()
		new_indices.resize(box_mesh.indices.size())
		
		if index_offset > 0:
			for i in range(box_mesh.indices.size()):
				new_indices[i] = box_mesh.indices[i] + index_offset
		
			# neue Indexes hinzufügen
			sm.indices += new_indices
		else:
			sm.indices = box_mesh.indices

		# zum Smartmesh hinzufügen
		sm.vertices += vertices # * pos_and_scale
		sm.normals += normals # gedrehte normals
		
		## Farben
		colors += generate_color_array(vertices.size(), box.color_number)
		
		
	## Teil 2: Soll um 5 Einheiten nach rechts verschoben werden
	#var teil_2: PackedVector3Array = ressource_rechts.vertices
	#var verschiebung = Transform3D().translated(Vector3(5.0, 0.0, 0.0))
	#
	## Die Multiplikation verschiebt alle Vertices und gibt ein neues Array zurück
	# var kombiniert: PackedVector3Array = array_links + (verschiebung * array_rechts)
	# oder var teil_2_verschoben = verschiebung * teil_2

		
	# ArrayMesh befüllen
# ArrayMesh befüllen
	var mesh_arrays = []
	mesh_arrays.resize(Mesh.ARRAY_MAX)
	mesh_arrays[Mesh.ARRAY_VERTEX] = sm.vertices
	mesh_arrays[Mesh.ARRAY_NORMAL] = sm.normals
	mesh_arrays[Mesh.ARRAY_INDEX] = sm.indices
	mesh_arrays[Mesh.ARRAY_COLOR] = colors
	
	# Vorhandene Oberflächen löschen
	mesh.clear_surfaces()
	
	# Direkte Übergabe an das ArrayMesh (Blendschnell, da nativ in C++)
	if sm.vertices.size() > 0:
		mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, mesh_arrays)

	# Material setzen
	if BASE_MATERIAL == null:
		BASE_MATERIAL = load("res://addons/smartmesh/vertex_material.material") 
	
	if mesh.get_surface_count() > 0:
		mesh.surface_set_material(0, BASE_MATERIAL)
	
	# Geändertes Mesh zurückgeben
	return mesh



# Variablen zum Mesch Zusammenbauen
# für create_multi_instance und create_mesh_instance
static var parent: Node3D
static var surface_list:Array = []
static var material_list:Array = []
static var mesh_list:Array = []


# MultiMeshInstanz erstellen
static func create_multi_instance(node:Node3D):
	parent = node.get_parent_node_3d()
	mesh_list = []
	surface_list = []
	material_list = []
	_iterate(node, 2) # 2: Multimesh
	_create_multi()
	
# SingleMesh erstellen
static func create_mesh_instance(node:Node3D):
	mesh_list = []
	surface_list = []
	material_list = []
	_iterate(node, 1) # 1: SingleMesh
	_create_single(node)


# Alle Nodes durchgehen
# modus=1 -> Single Mesh
# modus=2 -> Multi Meshes or Single Meshes
static func _iterate(node:Node, modus:int):
	if !node:
		return
	
	# Wenn die Node eine MeshInstance3D ist
	if node is MeshInstance3D:
		match(modus):
			1:
				_get_single(node)
			2:
				_get_multi(node)
	elif node is MultiMeshInstance3D:
		match(modus):
			1:
				_get_single_m(node)
			2:
				_get_multi_m(node)

		
	# Alle Kind Nodes von der Node durchgehen
	for child in node.get_children():
		_iterate(child, modus)


# MultiMesches prüfen 
static func _get_multi(meshinst:MeshInstance3D):
	var mesh:Mesh = meshinst.mesh
	
	# Prüfen ob schon vorhanden
	for i in range(mesh_list.size()):
		if mesh_list[i].mesh == mesh:
			# neues Transform
			mesh_list[i].transf.append(meshinst.transform)
			
			# Zurück
			return
			
	# wenn noch nicht vorhanden
	# neues Multimesh hinzufügen
	mesh_list.append({
		"mesh": mesh
		, "transf": [meshinst.transform]
	})
	
	
static func _get_multi_m(meshinst:MultiMeshInstance3D):
	var multi:MultiMesh = meshinst.multimesh
	var mesh:Mesh = meshinst.multimesh.mesh
	
	# Prüfen ob schon vorhanden
	for i in range(mesh_list.size()):
		if mesh_list[i].mesh == mesh:
			# neues Transform
			for j in range(multi.instance_count):
				var transf:Transform3D = multi.get_instance_transform(j)
				transf = transf.rotated(Vector3(1,0,0), meshinst.rotation.x)
				transf = transf.rotated(Vector3(0,1,0), meshinst.rotation.y)
				transf = transf.rotated(Vector3(0,0,1), meshinst.rotation.z)
				transf = transf.scaled(meshinst.scale)
				transf.origin = meshinst.transform.origin + transf.origin
				mesh_list[i].transf.append(transf)
			
			# Zurück
			return
			
	# wenn noch nicht vorhanden
	var new_mesh = {
		"mesh": mesh
		, "transf": []
	}
	
	# neues Transform
	for j in range(multi.instance_count):
		var transf:Transform3D = multi.get_instance_transform(j)
		transf = transf.rotated(Vector3(1,0,0), meshinst.rotation.x)
		transf = transf.rotated(Vector3(0,1,0), meshinst.rotation.y)
		transf = transf.rotated(Vector3(0,0,1), meshinst.rotation.z)
		transf = transf.scaled(meshinst.scale)
		transf.origin = meshinst.transform.origin + transf.origin
		new_mesh.transf.append(transf)
	
	# neues Multimesh hinzufügen
	mesh_list.append(new_mesh)


# Alle Surfaces prüfen 
# und alle mit gleichen Material zusammenführen
static func _get_single(meshinst: MeshInstance3D):
	var mesh:Mesh = meshinst.mesh

	# Alle Surfaces im Mesh durchgehen
	for i in range(mesh.get_surface_count()):	
		var mat:Material = mesh.surface_get_material(i)
		
		# SurfaceTool prüfen
		var st:SurfaceTool = SurfaceTool.new()
		var isMaterial:bool = false
		for j in range(material_list.size()):
			var test_mat = material_list[j]
			if test_mat == mat:
				st = surface_list[j]
				isMaterial = true
				break

		# Wenn noch kein Material
		if isMaterial == false:
			# Material und Surfacetool merken
			st.set_material(mat)
			material_list.append(mat)
			surface_list.append(st)
		
		# Surface Daten hinzufügen
		st.append_from(mesh, i, meshinst.transform)
		
static func _get_single_m(meshinst: MultiMeshInstance3D):
	var multi:MultiMesh = meshinst.multimesh
	var mesh:Mesh = multi.mesh

	# Alle Surfaces im Mesh durchgehen
	for i in range(mesh.get_surface_count()):	
		var mat:Material = mesh.surface_get_material(i)
		
		# SurfaceTool prüfen
		var st:SurfaceTool = SurfaceTool.new()
		var isMaterial:bool = false
		for j in range(material_list.size()):
			var test_mat = material_list[j]
			if test_mat == mat:
				st = surface_list[j]
				isMaterial = true
				break

		# Wenn noch kein Material
		if isMaterial == false:
			# Material und Surfacetool merken
			st.set_material(mat)
			material_list.append(mat)
			surface_list.append(st)
		
		# Surface Daten hinzufügen
		for j in range(multi.instance_count):
			var transf:Transform3D = multi.get_instance_transform(j)
			transf = transf.rotated(Vector3(1,0,0), meshinst.rotation.x)
			transf = transf.rotated(Vector3(0,1,0), meshinst.rotation.y)
			transf = transf.rotated(Vector3(0,0,1), meshinst.rotation.z)
			transf = transf.scaled(meshinst.scale)
			transf.origin = meshinst.transform.origin + transf.origin
			st.append_from(mesh, i, transf)
		
		#st.append_from(mesh, i, meshinst.transform)


# erzeuge Multimesh Instanzen
static func _create_multi():
	# Mesh Liste durchgehen
	for i in range(mesh_list.size()):
		var new_mesh = mesh_list[i]
		var count = new_mesh.transf.size()
		
		# wenn mehrere Instanzen
		if count > 1:
			var mm:MultiMesh = MultiMesh.new()
			mm.transform_format = MultiMesh.TRANSFORM_3D
			mm.instance_count = count
			mm.mesh = new_mesh.mesh
			for j in range(count):
				mm.set_instance_transform(j, new_mesh.transf[j])
			var mmi:MultiMeshInstance3D = MultiMeshInstance3D.new()
			mmi.multimesh = mm
			mmi.name = "multi_" + str(i)
			parent.add_child(mmi)
			mmi.owner = parent.owner
		else:
			# nur eine Mesh
			var mi:MeshInstance3D = MeshInstance3D.new()
			mi.mesh = new_mesh.mesh
			mi.transform = new_mesh.transf[0]
			mi.name = "mesh_" + str(i)
			parent.add_child(mi)
			mi.owner = parent.owner


# erzeuge (single) MeshInstance
static func _create_single(node:Node3D):
	var am:ArrayMesh = ArrayMesh.new()
	
	# Alle Oberflächen durchgehen
	for i in range(surface_list.size()):
		var st:SurfaceTool = surface_list[i]
		st.commit(am)
	
	var mi:MeshInstance3D = MeshInstance3D.new()
	mi.mesh = am
	mi.transform = node.transform
	mi.name = "mesh_instance"
	parent.add_child(mi)
	mi.owner = node.owner
