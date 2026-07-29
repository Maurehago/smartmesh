@tool
@icon("res://addons/smartmesh/mesh_icon.svg")
extends MeshInstance3D
class_name Smart3D

# Größe angeben
@export_group("Size")
@export_range(0.1, 8.0, 0.001) var size_x:float = 1.0:
	set(v):size_x = _berechne_snapped_wert(v, "x"); update_gizmos(); _generate()
@export_range(0.1, 8.0, 0.001) var size_y:float = 1.0:
	set(v):size_y = _berechne_snapped_wert(v, "y"); update_gizmos(); _generate()
@export_range(0.1, 8.0, 0.001) var size_z:float = 1.0:
	set(v):size_z =  _berechne_snapped_wert(v, "z"); update_gizmos(); _generate()

# Snapping
@export_group("Snap")
@export_enum("1.0", "0.1", "0.01", "0.001") var snapp_x: String = "0.1"
@export_enum("1.0", "0.1", "0.01", "0.001") var snapp_y: String = "0.1"
@export_enum("1.0", "0.1", "0.01", "0.001") var snapp_z: String = "0.1"
@export var snap_position:bool = true
@export var snap_rotation:bool = true

# Interner Speicher für alle dynamischen Inspektor-Werte
var _smart_properties: Dictionary = {}

# Konfiguration: Was möchte der Kind-Generator nutzen?
var _requested_colors: Dictionary = {} # {"variable_name": farb_index} 
var _requested_dropdowns: Dictionary = {} # {"variable_name": "ordner_name"}
var _requested_arrays: Dictionary = {}    # {"variable_name": "ordner_name"}


# Interne Variable - wird von smart_gizmo.gd verwendet das bei Größenänderungen kein flackern auftritt
var _temp_size: Vector3 = Vector3(-1, -1, -1)
var _temp_offset: Vector3 = Vector3.ZERO # Speichert die temporäre Verschiebung während des Ziehens

func _init() -> void:
	# Teilt Godot mit, dass diese Node auf Positionsänderungen reagieren soll
	set_notify_transform(true)

func _ready() -> void:
	if not self.mesh:
		self.mesh = ArrayMesh.new()

func _notification(what: int) -> void:
	# Wird im Editor aufgerufen, wenn die Node verschoben, rotiert oder skaliert wird
	if what == NOTIFICATION_TRANSFORM_CHANGED:
		if Engine.is_editor_hint():
			_rasten_auf_3d_raster()

# Hilfsfunktion, die das Snapping und das Limit (0.01 bis 8.0) berechnet
func _berechne_snapped_wert(eingabe_wert: float, axis:String) -> float:
	var schritt:float # snapping.to_float()
	if axis == "x":
		schritt = snapp_x.to_float()
	elif axis == "y":
		schritt = snapp_y.to_float()
	else:
		schritt = snapp_z.to_float()
	
	# 1. Auf das eingestellte Raster runden
	var gerundeter_wert = snapped(eingabe_wert, schritt)
	# 2. Innerhalb der Culling-Grenzen (0.01 bis 8.0) halten
	return clampf(gerundeter_wert, schritt, 8.0)


# Berechnet das Einrasten der globalen Position
func _rasten_auf_3d_raster() -> void:
	var schritt_x = snapp_x.to_float()
	var schritt_y = snapp_y.to_float()
	var schritt_z = snapp_z.to_float()
	
	var aktuelle_pos = global_position
	var neue_pos = aktuelle_pos
	
	if snap_position:
		# -------------------------------------------------------------------------
		# 1. MATHEMATISCHE KORREKTUR FÜR ZENTRIERTE PIVOTS
		# -------------------------------------------------------------------------
		# Wenn die Hälfte der Größe kein glattes Vielfaches des Rasters ist,
		# müssen wir die Einrast-Position um eine halbe Rasterweite verschieben.
		var local_offset = Vector3(
			fmod(size_x / 2.0, schritt_x)
			, fmod(size_y / 2.0, schritt_y)
			, fmod(size_z / 2.0, schritt_z)
		)
		
		# GLOBALER VERSATZ: Hier passiert die Magie!
		# Wir rotieren den lokalen Versatz-Vektor mit der 'basis' der Node.
		# Dadurch dreht sich der Versatz exakt so mit, wie das Objekt im Editor gedreht wurde.
		# Wir nehmen den Absolutwert (abs()), da die Richtung für das Snapping egal ist.
		var global_offset = (global_transform.basis * local_offset).abs()
		
		# Vor dem Runden ziehen wir den Versatz ab, und rechnen ihn danach wieder drauf.
		# Dadurch rasten die AUßENKANTEN perfekt ein, egal wie groß das Objekt ist!
		var snapped_x = snapped(aktuelle_pos.x - global_offset.x, schritt_x) + global_offset.x
		var snapped_y = snapped(aktuelle_pos.y - global_offset.y, schritt_y) + global_offset.y
		var snapped_z = snapped(aktuelle_pos.z - global_offset.z, schritt_z) + global_offset.z
		
		neue_pos = Vector3(snapped_x, snapped_y, snapped_z)
	
	# -------------------------------------------------------------------------
	# 2. ROTATIONS-SNAP (15°-SCHRITTE)
	# -------------------------------------------------------------------------
	var aktuelle_rot = global_rotation_degrees
	var schritt_grad = 15.0
	var neue_rot = aktuelle_rot
	
	if snap_rotation:
		var snapped_rot_x = snapped(aktuelle_rot.x, schritt_grad)
		var snapped_rot_y = snapped(aktuelle_rot.y, schritt_grad)
		var snapped_rot_z = snapped(aktuelle_rot.z, schritt_grad)
	
		neue_rot = Vector3(snapped_rot_x, snapped_rot_y, snapped_rot_z)
	
	# -------------------------------------------------------------------------
	# 3. TRANSFORMATION ANWENDEN
	# -------------------------------------------------------------------------
	# Prüfen, ob sich Position oder Rotation signifikant geändert haben
	var pos_geandert = aktuelle_pos.distance_to(neue_pos) > 0.001
	var rot_geandert = aktuelle_rot.distance_to(neue_rot) > 0.01
	
	if pos_geandert or rot_geandert:
		# Da wir uns in einer Transform-Meldung befinden, nutzen wir set_deferred,
		# um unendliche Engine-Schleifen und Abstürze zu verhindern.
		if pos_geandert:
			set_deferred("global_position", neue_pos)
		if rot_geandert:
			set_deferred("global_rotation_degrees", neue_rot)


# =====================================
#   hilfsfunktion für Modifikatoren
# ----------------------------------
## Verwaltet rein die Signal-Verbindungen und gibt das neue Array zurück
func update_modifier_signals(old_mods: Array[SmartModifier], new_mods: Array[SmartModifier]) -> Array[SmartModifier]:
	for m in old_mods:
		if m and m.changed.is_connected(_on_modifier_changed):
			m.changed.disconnect(_on_modifier_changed)
			
	for m in new_mods:
		if m and not m.changed.is_connected(_on_modifier_changed):
			m.changed.connect(_on_modifier_changed)
			
	return new_mods
	
## Callback für Signal-Änderungen IM Modifier
func _on_modifier_changed() -> void:
	_generate()


# -----------------------------------------------------------------------------
# REGISTRIERUNGS-FUNKTIONEN Für SmartMesh Auswahl
# -----------------------------------------------------------------------------
## Farbauswahl registrieren
func register_color(property_name:String, default_color:float = 0.0):
	_requested_colors[property_name] = property_name
	
	if not _smart_properties.has(property_name):
		_smart_properties[property_name] = default_color

func register_dropdown(property_name: String, group_folders: Variant, default_value: String = "") -> void:
	# Wenn es ein einzelner String ist, packen wir ihn in ein Array
	if typeof(group_folders) == TYPE_STRING:
		_requested_dropdowns[property_name] = [group_folders] as Array[String]
	else:
		_requested_dropdowns[property_name] = group_folders as Array[String]
		
	if not _smart_properties.has(property_name):
		_smart_properties[property_name] = default_value

func register_array(property_name: String, group_folders: Variant) -> void:
	# Wenn es ein einzelner String ist, packen wir ihn in ein Array
	if typeof(group_folders) == TYPE_STRING:
		_requested_arrays[property_name] = [group_folders] as Array[String]
	else:
		_requested_arrays[property_name] = group_folders as Array[String]
		
	if not _smart_properties.has(property_name):
		_smart_properties[property_name] = [] as Array[String]

# ==============================================================

# Jedes Mal, wenn der User im Inspektor etwas ändert, fängt die Basisklasse das ab
func _set(property: StringName, value: Variant) -> bool:
	if _smart_properties.has(property):
		if property in _requested_colors:
			_smart_properties[property] = int(value)
		else:
			_smart_properties[property] = value
		_generate() # Mesh neu generieren
		return true
	return false

func _get(property: StringName) -> Variant:
	if _smart_properties.has(property):
		return _smart_properties[property]
	return null

# Bequeme Helfer-Funktion, damit der Generator an seine Werte kommt
func get_smart_val(property_name: String) -> Variant:
	return _smart_properties.get(property_name)

# ===================================================================

# -----------------------------------------------------------------------------
# ZENTRALE INSPEKTOR-ERZEUGUNG
# -----------------------------------------------------------------------------
func _get_property_list() -> Array[Dictionary]:
	var properties: Array[Dictionary] = []

	# Farbauswahl hinzufügen
	if not _requested_colors.is_empty():
		properties.append({"name": "Colors", "type": TYPE_NIL, "usage": PROPERTY_USAGE_GROUP})
		for prop_name in _requested_colors:
			properties.append({
				"name": prop_name,
				"type": TYPE_FLOAT,
				"hint": PROPERTY_HINT_RANGE,
				"hint_string": "0.0, 79.0, 1.0", 
				"usage": PROPERTY_USAGE_DEFAULT # Macht es im Inspektor sichtbar & speichert es in der Szene
			})
	
	# 1. Registrierte Dropdowns hinzufügen
	if not _requested_dropdowns.is_empty():
		properties.append({"name": "SmartMesh (Select)", "type": TYPE_NIL, "usage": PROPERTY_USAGE_GROUP})
		for prop_name in _requested_dropdowns:
			var folders = _requested_dropdowns[prop_name] # Das ist jetzt immer ein Array!
			var combined_items := PackedStringArray()
			
			# Alle Ressourcen aus allen angegebenen Ordnern sammeln
			for folder in folders:
				combined_items.append_array(Smart.get_resources_for_group(folder))
				
			var items_string = ",".join(combined_items)
			properties.append({
				"name": prop_name,
				"type": TYPE_STRING,
				"hint": PROPERTY_HINT_ENUM,
				"hint_string": items_string if items_string != "" else "Ordner leer",
				"usage": PROPERTY_USAGE_DEFAULT
			})
			
	# 2. Registrierte Arrays hinzufügen
	if not _requested_arrays.is_empty():
		properties.append({"name": "SmartMesh (Pools)", "type": TYPE_NIL, "usage": PROPERTY_USAGE_GROUP})
		for prop_name in _requested_arrays:
			var folders = _requested_arrays[prop_name] # Das ist jetzt immer ein Array!
			var combined_items := PackedStringArray()
			
			# Alle Ressourcen aus allen angegebenen Ordnern sammeln
			for folder in folders:
				combined_items.append_array(Smart.get_resources_for_group(folder))
				
			var items_string = ",".join(combined_items)
			properties.append({
				"name": prop_name,
				"type": TYPE_ARRAY,
				"hint": PROPERTY_HINT_ARRAY_TYPE,
				"hint_string": "%d/%d:%s" % [TYPE_STRING, PROPERTY_HINT_ENUM, items_string],
				"usage": PROPERTY_USAGE_DEFAULT
			})
			
	return properties



## Generiert das Mesh
## Diese Funktion muss überschrieben werden
func _generate():
	#print("generate wall")
	if !self.mesh:
		self.mesh = ArrayMesh.new()
		
